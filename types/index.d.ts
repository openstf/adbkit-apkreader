// Type definitions for adbkit-apkreader 3.1.0
/// <reference types='node' />

import fs = require('fs');

type activity = {
  name: string,
  label?: string|undefined,
  theme?: string|undefined,
  configChanges?: number|undefined,
  screenOrientation?: number|undefined,
  launchMode?: number|undefined,
  windowSoftInputMode?: number|undefined,
  hardwareAccelerated?: boolean|undefined,
  exported?: boolean|undefined,
  excludeFromRecents?: boolean|undefined,
  intentFilters?: Array<{
    actions: {name: string},
    categories: {name: string},
    data: Array<any>,
    [key: string]: any,
  }>|undefined,
  metaData?: Array<{
    name: string,
    value: boolean,
  }>|undefined,
  [key: string]: any,
}

type manifest = {
  versionCode: number,
  versionName: string,
  compileSdkVersion?: number|undefined,
  compileSdkVersionCodename?: string|undefined,
  installLocation?: number|undefined,
  package: string,
  platformBuildVersionCode?: number|undefined,
  platformBuildVersionName?: string|undefined,
  usesPermissions: Array<{name: string, maxSdkVersion?: number|undefined}>,
  permissions: Array<{name: string, protectionLevel: number}>,
  permissionTrees: Array<any>,
  permissionGroups: Array<any>,
  instrumentation: any|null,
  usesSdk: { minSdkVersion: number, targetSdkVersion: number },
  usesConfiguration: any|null,
  usesFeatures: Array<{name?: string|undefined, required?: boolean|undefined, glEsVersion?: number|undefined}>,
  supportsScreens: {
    anyDensity?: boolean|undefined,
    smallScreens?: boolean|undefined,
    normalScreens?: boolean|undefined,
    largeScreens?: boolean|undefined,
    xlargeScreens?: boolean|undefined,
    [key: string]: boolean|undefined,
  } | null,
  compatibleScreens: Array<{ screenSize: number, screenDensity: number }>,
  supportsGlTextures: Array<any>,
  application: {
    theme?: string|undefined,
    label?: string|undefined,
    icon?: string|undefined,
    roundIcon?: string|undefined,
    name?: string|undefined,
    banner?: string|undefined,
    screenOrientation?: number|undefined,
    debuggable?: boolean|undefined,
    allowBackup?: boolean|undefined,
    usesCleartextTraffic?: boolean|undefined,
    supportsRtl?: boolean|undefined,
    isGame?: boolean|undefined,
    activities: activity[],
    activityAliases: Array<any>,
    launcherActivities: activity[],
    services: Array<{
      name: string,
      enabled?: boolean|string|undefined,
      exported?: boolean|undefined,
      permission?: string|undefined,
      intentFilters?: Array<{
        actions: {name: string},
        categories: {name: string},
        data: Array<any>,
        [key: string]: any,
      }>|undefined,
      metaData?: Array<any>,
      [key: string]: any,
    }>|undefined,
    receivers: Array<{
      name: string,
      enabled?: boolean|string|undefined,
      exported?: boolean|undefined,
      permission?: string|undefined,
      intentFilters?: Array<{
        actions: {name: string},
        categories: {name: string},
        data: Array<any>,
        [key: string]: any,
      }>|undefined,
      metaData?: Array<any>,
      [key: string]: any,
    }>|undefined,
    providers: Array<{
      name: string,
      enabled?: boolean|string|undefined,
      exported?: boolean|undefined,
      authorities?: string|undefined,
      initOrder?: number|undefined,
      grantUriPermissions?: Array<any>|undefined,
      metaData?: Array<any>|undefined,
      pathPermissions?: Array<any>|undefined,
      [key: string]: any,
    }>,
    usesLibraries: Array<{ name: string, required: boolean }>,
    [key: string]: any,
  },
}

type attribute = {
  namespaceURI: string|null,
  nodeType: number,
  nodeName: string,
  name: string,
  value: string|null,
  typedValue: {
    valeu: string|number,
    type: string,
    rawType: number,
  }
}

type xmlNode = {
  namespaceURI: string|null,
  nodeType: number,
  nodeName: string,
  attributes: Array<attribute>,
  childNodes: Array<xmlNode>,
}


declare class ApkReader {
  public static MANIFEST(): 'AndroidManifest.xml';
  public static open(apk: string): Promise<ApkReader>;

  public readContent(path: string): Promise<Buffer>;
  public readManifest(options?: {debug: boolean}): Promise<manifest>;
  public readXml(path: string, options?: {debug: boolean}): Promise<xmlNode>;
  public usingFileStream<T>(path: string, action: (stream: fs.ReadStream) => Promise<T> ): Promise<T>;
}

export = ApkReader;