Zip = require 'adm-zip'

# Heavily inspired by https://github.com/xiaxiaocao/apk-parser

class BinaryXmlParser
  ChunkType =
    NULL: 0x0000
    STRING_POOL: 0x0001
    TABLE: 0x0002
    XML: 0x0003
    XML_FIRST_CHUNK: 0x0100
    XML_START_NAMESPACE: 0x0100
    XML_END_NAMESPACE: 0x0101
    XML_START_ELEMENT: 0x0102
    XML_END_ELEMENT: 0x0103
    XML_CDATA: 0x0104
    XML_LAST_CHUNK: 0x017f
    XML_RESOURCE_MAP: 0x0180
    TABLE_PACKAGE: 0x0200
    TABLE_TYPE: 0x0201
    TABLE_TYPE_SPEC: 0x0202

  StringFlags =
    SORTED: 1 << 0
    UTF8: 1 << 8

  ResType =
    # Contains no data.
    NULL: 0x00
    # The 'data' holds a ResTable_ref; a reference to another resource
    # table entry.
    REFERENCE: 0x01
    # The 'data' holds an attribute resource identifier.
    ATTRIBUTE: 0x02
    # The 'data' holds an index into the containing resource table's
    # global value string pool.
    STRING: 0x03
    # The 'data' holds a single-precision floating point number.
    FLOAT: 0x04
    # The 'data' holds a complex number encoding a dimension value;
    # such as "100in".
    DIMENSION: 0x05
    # The 'data' holds a complex number encoding a fraction of a
    # container.
    FRACTION: 0x06
    # Beginning of integer flavors...
    FIRST_INT: 0x10
    # The 'data' is a raw integer value of the form n..n.
    INT_DEC: 0x10
    # The 'data' is a raw integer value of the form 0xn..n.
    INT_HEX: 0x11
    # The 'data' is either 0 or 1; for input "false" or "true" respectively.
    INT_BOOLEAN: 0x12
    # Beginning of color integer flavors...
    FIRST_COLOR_INT: 0x1c
    # The 'data' is a raw integer value of the form #aarrggbb.
    INT_COLOR_ARGB8: 0x1c
    # The 'data' is a raw integer value of the form #rrggbb.
    INT_COLOR_RGB8: 0x1d
    # The 'data' is a raw integer value of the form #argb.
    INT_COLOR_ARGB4: 0x1e
    # The 'data' is a raw integer value of the form #rgb.
    INT_COLOR_RGB4: 0x1f
    # ...end of integer flavors.
    LAST_COLOR_INT: 0x1f
    # ...end of integer flavors.
    LAST_INT: 0x1f

  constructor: (@buffer) ->
    @cursor = 0
    @strings = []
    @resources = []
    @document = null
    @parent = null
    @stack = []

  readU8: ->
    val = @buffer[@cursor]
    @cursor += 1
    return val

  readU16: ->
    val = @buffer.readUInt16LE @cursor
    @cursor += 2
    return val

  readS32: ->
    val = @buffer.readInt32LE @cursor
    @cursor += 4
    return val

  readU32: ->
    val = @buffer.readUInt32LE @cursor
    @cursor += 4
    return val

  readLength8: ->
    len = this.readU8()
    if len & 0x80
      len = (len & 0x7f) << 7
      len += this.readU8()
    return len

  readLength16: ->
    len = this.readU16()
    if len & 0x8000
      len = (len & 0x7fff) << 15
      len += this.readU16()
    return len

  readString: (encoding) ->
    switch encoding
      when 'utf-8'
        stringLength = this.readLength8 encoding
        byteLength = this.readLength8 encoding
        value = @buffer.toString encoding, @cursor, @cursor += byteLength
        @cursor += 2 # Skip trailing short zero
        return value
      when 'ucs2'
        stringLength = this.readLength16 encoding
        byteLength = stringLength * 2
        value = @buffer.toString encoding, @cursor, @cursor += byteLength
        @cursor += 2 # Skip trailing short zero
        return value
      else
        throw new Error "Unsupported encoding '#{encoding}'"

  readChunkHeader: ->
    chunkType: this.readU16()
    headerSize: this.readU16()
    chunkSize: this.readU32()

  readStringPool: (header) ->
    header.stringCount = this.readU32()
    header.styleCount = this.readU32()
    header.flags = this.readU32()
    header.stringsStart = this.readU32()
    header.stylesStart = this.readU32()

    if header.chunkType isnt ChunkType.STRING_POOL
      throw new Error 'Invalid string pool header'

    anchor = @cursor

    offsets = []
    offsets.push this.readU32() for [0...header.stringCount]

    #sorted = stringPoolHeader.flags & StringFlags.SORTED
    encoding =
      if header.flags & StringFlags.UTF8
        'utf-8'
      else
        'ucs2'

    @cursor = anchor + header.stringsStart - header.headerSize
    @strings.push this.readString encoding for [0...header.stringCount]

    # Skip styles
    @cursor = anchor + header.chunkSize - header.headerSize

  readResourceMap: (header) ->
    count = Math.floor (header.chunkSize - header.headerSize) / 4
    @resources.push this.readU32() for [0...count]

  readXmlNamespaceStart: (header) ->
    line = this.readU32()
    commentRef = this.readU32()
    prefixRef = this.readS32()
    uriRef = this.readS32()

    # @namespace.prefix = @strings[prefixRef] if prefixRef > 0
    # @namespace.uri = @strings[uriRef] if uriRef > 0

  readXmlNamespaceEnd: (header) ->
    line = this.readU32()
    commentRef = this.readU32()
    prefixRef = this.readS32()
    uriRef = this.readS32()

    # @namespace.prefix = @strings[prefixRef] if prefixRef > 0
    # @namespace.uri = @strings[uriRef] if uriRef > 0

  readXmlElementStart: (header) ->
    node =
      namespace: null
      name: null
      attributes: []
      children: []

    line = this.readU32()
    commentRef = this.readU32()
    nsRef = this.readS32()
    nameRef = this.readS32()

    node.namespace = @strings[nsRef] if nsRef > 0
    node.name = @strings[nameRef]

    attrStart = this.readU16()
    attrSize = this.readU16()
    attrCount = this.readU16()
    idIndex = this.readU16()
    classIndex = this.readU16()
    styleIndex = this.readU16()

    node.attributes.push this.readXmlAttribute() for [0...attrCount]

    if @document
      @parent.children.push node
      @parent = node
    else
      @document = @parent = node

    @stack.push node

    return node

  readXmlAttribute: ->
    attr =
      namespace: null
      name: null
      rawValue: null
      value: null

    nsRef = this.readS32()
    nameRef = this.readS32()
    valueRef = this.readS32()
    size = this.readU16()
    zero = this.readU8()
    dataType = this.readU8()

    attr.namespace = @strings[nsRef] if nsRef > 0
    attr.name = @strings[nameRef]
    attr.rawValue = @strings[valueRef]
    attr.dataType = dataType

    switch dataType
      when ResType.INT_DEC, ResType.INT_HEX
        attr.value = this.readU32()
      when ResType.STRING
        ref = this.readS32()
        attr.value = @strings[ref] if ref > 0
      when ResType.REFERENCE
        id = this.readU32()
        attr.value = "res:#{id}"
      when ResType.INT_BOOLEAN
        attr.value = this.readS32() isnt 0
      when ResType.NULL
        attr.value = null
      when ResType.INT_COLOR_RGB8, ResType.INT_COLOR_RGB4
        # problem
        false
      when ResType.INT_COLOR_ARGB8, ResType.INT_COLOR_ARGB4
        # problem
        false
      when ResType.DIMENSION
        # problem
        false
      when ResType.FRACTION
        # problem
        false
      else
        res.value = this.readU32()

    return attr

  readXmlElementEnd: (header) ->
    node =
      namespace: null
      name: null
      attributes: []

    line = this.readU32()
    commentRef = this.readU32()
    nsRef = this.readS32()
    nameRef = this.readS32()

    node.namespace = @strings[nsRef] if nsRef > 0
    node.name = @strings[nameRef]

    @stack.pop()
    @parent = @stack[@stack.length - 1]

    return node

  readNull: (header) ->
    @cursor += header.chunkSize - header.headerSize

  parse: ->
    xmlHeader = this.readChunkHeader()
    if xmlHeader.chunkType isnt ChunkType.XML
      throw new Error 'Invalid XML header'

    this.readStringPool this.readChunkHeader()

    resMapHeader = this.readChunkHeader()
    if resMapHeader.chunkType is ChunkType.XML_RESOURCE_MAP
      this.readResourceMap resMapHeader
      this.readXmlNamespaceStart this.readChunkHeader()
    else
      this.readXmlNamespaceStart resMapHeader

    while @cursor < @buffer.length
      header = this.readChunkHeader()
      switch header.chunkType
        when ChunkType.XML_START_NAMESPACE
          this.readXmlNamespaceStart header
          #throw new Error 'Multiple namespaces'
        when ChunkType.XML_END_NAMESPACE
          this.readXmlNamespaceEnd header
        when ChunkType.XML_START_ELEMENT
          this.readXmlElementStart header
        when ChunkType.XML_END_ELEMENT
          this.readXmlElementEnd header
        when ChunkType.XML_CDATA
          this.readXmlCData header
        when ChunkType.NULL
          this.readNull header
        else
          throw new Error "Unsupported chunk type '#{header.chunkType}'"

    return @document

module.exports = BinaryXmlParser
