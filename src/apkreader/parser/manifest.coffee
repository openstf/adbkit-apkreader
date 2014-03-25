BinaryXmlParser = require './binaryxml'

class ManifestParser
  NS_ANDROID = 'http://schemas.android.com/apk/res/android'
  INTENT_MAIN = 'android.intent.action.MAIN'
  CATEGORY_LAUNCHER = 'android.intent.category.LAUNCHER'

  constructor: (@buffer) ->
    @xmlParser = new BinaryXmlParser @buffer

  collapseAttributes: (element) ->
    collapsed = Object.create null
    for attr in element.attributes
      collapsed[attr.name] = attr.typedValue.value
    return collapsed

  parseIntents: (element, target) ->
    target.intentFilters = []
    target.metaData = []

    element.children.forEach (element) =>
      switch element.name
        when 'intent-filter'
          intentFilter = this.collapseAttributes element

          intentFilter.actions = []
          intentFilter.categories = []
          intentFilter.data = []

          element.children.forEach (element) =>
            switch element.name
              when 'action'
                intentFilter.actions.push this.collapseAttributes element
              when 'category'
                intentFilter.categories.push this.collapseAttributes element
              when 'data'
                intentFilter.data.push this.collapseAttributes element

          target.intentFilters.push intentFilter
        when 'meta-data'
          target.metaData.push this.collapseAttributes element

  parseApplication: (element) ->
    app = this.collapseAttributes element

    app.activities = []
    app.activityAliases = []
    app.launcherActivities = []
    app.services = []
    app.receivers = []
    app.providers = []
    app.usesLibraries = []

    element.children.forEach (element) =>
      switch element.name
        when 'activity'
          activity = this.collapseAttributes element
          this.parseIntents element, activity
          app.activities.push activity
          if this.isLauncherActivity activity
            app.launcherActivities.push activity
        when 'activity-alias'
          activityAlias = this.collapseAttributes element
          this.parseIntents element, activityAlias
          app.activityAliases.push activityAlias
          if this.isLauncherActivity activityAlias
            app.launcherActivities.push activityAlias
        when 'service'
          service = this.collapseAttributes element
          this.parseIntents element, service
          app.services.push service
        when 'receiver'
          receiver = this.collapseAttributes element
          this.parseIntents element, receiver
          app.receivers.push receiver
        when 'provider'
          provider = this.collapseAttributes element

          provider.grantUriPermissions = []
          provider.metaData = []
          provider.pathPermissions = []

          element.children.forEach (element) =>
            switch element.name
              when 'grant-uri-permission'
                provider.grantUriPermissions.push \
                  this.collapseAttributes element
              when 'meta-data'
                provider.metaData.push this.collapseAttributes element
              when 'path-permission'
                provider.pathPermissions.push \
                  this.collapseAttributes element

          app.providers.push provider
        when 'uses-library'
          app.usesLibraries.push this.collapseAttributes element

    return app

  isLauncherActivity: (activity) ->
    activity.intentFilters.some (filter) ->
      hasMain = filter.actions.some (action) ->
        action.name is INTENT_MAIN
      return false unless hasMain
      filter.categories.some (category) ->
        category.name is CATEGORY_LAUNCHER

  parse: ->
    document = @xmlParser.parse()

    manifest = this.collapseAttributes document

    manifest.usesPermissions = []
    manifest.permissions = []
    manifest.permissionTrees = []
    manifest.permissionGroups = []
    manifest.instrumentation = null
    manifest.usesSdk = null
    manifest.usesConfiguration = null
    manifest.usesFeatures = []
    manifest.supportsScreens = null
    manifest.compatibleScreens = []
    manifest.supportsGlTextures = []
    manifest.application = Object.create null

    document.children.forEach (element) =>
      switch element.name
        when 'uses-permission'
          manifest.usesPermissions.push this.collapseAttributes element
        when 'permission'
          manifest.permissions.push this.collapseAttributes element
        when 'permission-tree'
          manifest.permissionTrees.push this.collapseAttributes element
        when 'permission-group'
          manifest.permissionGroups.push this.collapseAttributes element
        when 'instrumentation'
          manifest.instrumentation = this.collapseAttributes element
        when 'uses-sdk'
          manifest.usesSdk = this.collapseAttributes element
        when 'uses-configuration'
          manifest.usesConfiguration = this.collapseAttributes element
        when 'uses-feature'
          manifest.usesFeatures.push this.collapseAttributes element
        when 'supports-screens'
          manifest.supportsScreens = this.collapseAttributes element
        when 'compatible-screens'
          element.children.forEach (screen) =>
            manifest.compatibleScreens.push this.collapseAttributes screen
        when 'supports-gl-texture'
          manifest.supportsGlTextures.push this.collapseAttributes element
        when 'application'
          manifest.application = this.parseApplication element

    return manifest

module.exports = ManifestParser
