// JCL_DEBUG_EXPERT_INSERTJDBG ON
program SASPlanet;

uses
  reinit,
  Forms,
  iniFiles,
  sysutils,
  windows,
  ijl in 'src\ijl.pas',
  ECWReader in 'src\ECWReader.pas',
  ECWwriter in 'src\ECWwriter.pas',
  SwinHttp in 'src\SwinHttp.pas',
  Langs in 'src\Langs.pas',
  u_WideStrings in 'src\u_WideStrings.pas',
  cUnicode in 'src\cUnicode.pas',
  cUnicodeChar in 'src\cUnicodeChar.pas',
  CPDrv in 'src\CPDrv.pas',
  BMSearch in 'src\BMSearch.pas',
  i_IGUIDList in 'src\i_IGUIDList.pas',
  u_GUIDList in 'src\u_GUIDList.pas',
  u_GUIDInterfaceList in 'src\u_GUIDInterfaceList.pas',
  u_GUIDObjectList in 'src\u_GUIDObjectList.pas',
  i_JclNotify in 'src\i_JclNotify.pas',
  u_JclNotify in 'src\u_JclNotify.pas',
  t_GeoTypes in 't_GeoTypes.pas',
  t_CommonTypes in 't_CommonTypes.pas',
  t_LoadEvent in 't_LoadEvent.pas',
  UTimeZones in 'UTimeZones.pas',
  UResStrings in 'UResStrings.pas',
  i_IConfigDataProvider in 'i_IConfigDataProvider.pas',
  u_ConfigDataProviderByVCLZip in 'u_ConfigDataProviderByVCLZip.pas',
  u_ConfigDataProviderByIniFile in 'u_ConfigDataProviderByIniFile.pas',
  u_ConfigDataProviderByIniFileSection in 'u_ConfigDataProviderByIniFileSection.pas',
  u_ConfigDataProviderByFolder in 'u_ConfigDataProviderByFolder.pas',
  i_ILogSimple in 'i_ILogSimple.pas',
  i_ILogForTaskThread in 'i_ILogForTaskThread.pas',
  i_ITileDownlodSession in 'i_ITileDownlodSession.pas',
  i_ISimpleFactory in 'i_ISimpleFactory.pas',
  i_IListOfObjectsWithTTL in 'i_IListOfObjectsWithTTL.pas',
  i_IObjectWithTTL in 'i_IObjectWithTTL.pas',
  i_IPoolElement in 'i_IPoolElement.pas',
  i_IMemObjCache in 'i_IMemObjCache.pas',
  i_ITileObjCache in 'i_ITileObjCache.pas',
  u_TileCacheSimpleGlobal in 'u_TileCacheSimpleGlobal.pas',
  u_BitmapLayerWithSortIndex in 'u_BitmapLayerWithSortIndex.pas',
  UTrAllLoadMap in 'UTrAllLoadMap.pas',
  u_ThreadMapCombineBase in 'u_ThreadMapCombineBase.pas',
  u_ThreadMapCombineBMP in 'u_ThreadMapCombineBMP.pas',
  u_ThreadMapCombineECW in 'u_ThreadMapCombineECW.pas',
  u_ThreadMapCombineJPG in 'u_ThreadMapCombineJPG.pas',
  u_ThreadMapCombineKMZ in 'u_ThreadMapCombineKMZ.pas',
  u_ThreadRegionProcessAbstract in 'u_ThreadRegionProcessAbstract.pas',
  u_ThreadExportAbstract in 'u_ThreadExportAbstract.pas',
  u_ThreadExportToZip in 'u_ThreadExportToZip.pas',
  u_ThreadExportToFileSystem in 'u_ThreadExportToFileSystem.pas',
  u_ThreadExportIPhone in 'u_ThreadExportIPhone.pas',
  u_ThreadExportKML in 'u_ThreadExportKML.pas',
  u_ThreadExportYaMaps in 'u_ThreadExportYaMaps.pas',
  u_ThreadExportToAUX in 'u_ThreadExportToAUX.pas',
  u_ThreadDeleteTiles in 'u_ThreadDeleteTiles.pas',
  u_ThreadGenPrevZoom in 'u_ThreadGenPrevZoom.pas',
  u_TileDownloaderBase in 'u_TileDownloaderBase.pas',
  u_TileDownloaderUI in 'u_TileDownloaderUI.pas',
  u_TileDownloaderUIOneTile in 'u_TileDownloaderUIOneTile.pas',
  u_TileDownloaderThreadBase in 'u_TileDownloaderThreadBase.pas',
  u_LogForTaskThread in 'u_LogForTaskThread.pas',
  u_MapLayerWiki in 'u_MapLayerWiki.pas',
  UPLT in 'UPLT.pas',
  Ugeofun in 'Ugeofun.pas',
  u_GlobalCahceConfig in 'u_GlobalCahceConfig.pas',
  u_GlobalState in 'u_GlobalState.pas',
  u_GeoToStr in 'u_GeoToStr.pas',
  u_KmlInfoSimple in 'u_KmlInfoSimple.pas',
  i_IKmlInfoSimpleLoader in 'i_IKmlInfoSimpleLoader.pas',
  u_KmlInfoSimpleParser in 'u_KmlInfoSimpleParser.pas',
  u_KmzInfoSimpleParser in 'u_KmzInfoSimpleParser.pas',
  UECWWrite in 'UECWWrite.pas',
  bmpUtil in 'bmpUtil.pas',
  Uimgfun in 'Uimgfun.pas',
  i_BitmapTileSaveLoad in 'i_BitmapTileSaveLoad.pas',
  u_BitmapTileJpegLoader in 'BitmapTileSaveLoad\u_BitmapTileJpegLoader.pas',
  u_BitmapTileJpegSaverIJL in 'BitmapTileSaveLoad\u_BitmapTileJpegSaverIJL.pas',
  u_BitmapTileVampyreLoader in 'BitmapTileSaveLoad\u_BitmapTileVampyreLoader.pas',
  u_BitmapTileVampyreSaver in 'BitmapTileSaveLoad\u_BitmapTileVampyreSaver.pas',
  i_IBitmapTypeExtManager in 'i_IBitmapTypeExtManager.pas',
  u_BitmapTypeExtManagerSimple in 'u_BitmapTypeExtManagerSimple.pas',
  u_MapTypeCacheConfig in 'u_MapTypeCacheConfig.pas',
  UMapType in 'UMapType.pas',
  i_MapTypeIconsList in 'i_MapTypeIconsList.pas',
  u_MapTypeIconsList in 'u_MapTypeIconsList.pas',
  u_MemFileCache in 'u_MemFileCache.pas',
  UYaMobile in 'UYaMobile.pas',
  UGSM in 'UGSM.pas',
  u_UrlGenerator in 'u_UrlGenerator.pas',
  i_ICoordConverter in 'i_ICoordConverter.pas',
  u_CoordConverterAbstract in 'u_CoordConverterAbstract.pas',
  u_CoordConverterBasic in 'u_CoordConverterBasic.pas',
  u_CoordConverterMercatorOnEllipsoid in 'u_CoordConverterMercatorOnEllipsoid.pas',
  u_CoordConverterMercatorOnSphere in 'u_CoordConverterMercatorOnSphere.pas',
  u_CoordConverterSimpleLonLat in 'u_CoordConverterSimpleLonLat.pas',
  u_TileIteratorAbstract in 'u_TileIteratorAbstract.pas',
  u_TileIteratorStuped in 'u_TileIteratorStuped.pas',
  u_GECache in 'u_GECache.pas',
  u_GECrypt in 'u_GECrypt.pas',
  u_GETexture in 'u_GETexture.pas',
  i_GeoCoder in 'i_GeoCoder.pas',
  u_GeoCodePalcemark in 'u_GeoCodePalcemark.pas',
  u_EnumUnknown in 'u_EnumUnknown.pas',
  u_GeoCodeResult in 'u_GeoCodeResult.pas',
  i_IProxySettings in 'i_IProxySettings.pas',
  u_GeoCoderBasic in 'u_GeoCoderBasic.pas',
  u_GeoCoderByYandex in 'u_GeoCoderByYandex.pas',
  u_GeoCoderByGoogle in 'u_GeoCoderByGoogle.pas',
  u_ProxySettingsFromTInetConnect in 'u_ProxySettingsFromTInetConnect.pas',
  u_GeoSearcher in 'u_GeoSearcher.pas',
  i_IMapViewGoto in 'i_IMapViewGoto.pas',
  u_MapViewGotoOnFMain in 'u_MapViewGotoOnFMain.pas',
  i_ISearchResultPresenter in 'i_ISearchResultPresenter.pas',
  u_SearchResultPresenterStuped in 'u_SearchResultPresenterStuped.pas',
  u_MarksSimple in 'u_MarksSimple.pas',
  u_MarksReadWriteSimple in 'u_MarksReadWriteSimple.pas',
  i_IBitmapLayerProvider in 'i_IBitmapLayerProvider.pas',
  u_MapMarksBitmapLayerProviderStuped in 'u_MapMarksBitmapLayerProviderStuped.pas',
  u_WindowLayerBasic in 'u_WindowLayerBasic.pas',
  u_MiniMapLayer in 'u_MiniMapLayer.pas',
  u_CenterScale in 'u_CenterScale.pas',
  u_LayerStatBar in 'u_LayerStatBar.pas',
  u_MapLayerBasic in 'u_MapLayerBasic.pas',
  u_MapTileLayerBasic in 'u_MapTileLayerBasic.pas',
  u_MapMainLayer in 'u_MapMainLayer.pas',
  u_MapMarksLayer in 'u_MapMarksLayer.pas',
  u_MapLayerNavToMark in 'u_MapLayerNavToMark.pas',
  u_MapFillingLayer in 'u_MapFillingLayer.pas',
  u_SelectionLayer in 'u_SelectionLayer.pas',
  u_LayerScaleLine in 'u_LayerScaleLine.pas',
  u_MapGPSLayer in 'u_MapGPSLayer.pas',
  u_MapLayerShowError in 'u_MapLayerShowError.pas',
  u_MapNalLayer in 'u_MapNalLayer.pas',
  u_MapLayerGoto in 'u_MapLayerGoto.pas',
  i_Marks in 'i_Marks.pas',
  u_MarkBasic in 'u_MarkBasic.pas',
  u_MarkCategory in 'u_MarkCategory.pas',
  u_MarksDb in 'u_MarksDb.pas' {DMMarksDb: TDataModule},
  u_EnumUnknownEmpty in 'u_EnumUnknownEmpty.pas',
  i_ITileFileNameGenerator in 'i_ITileFileNameGenerator.pas',
  u_TileFileNameSAS in 'u_TileFileNameSAS.pas',
  u_TileFileNameGMV in 'u_TileFileNameGMV.pas',
  u_TileFileNameES in 'u_TileFileNameES.pas',
  u_TileFileNameGM1 in 'u_TileFileNameGM1.pas',
  u_TileFileNameGM2 in 'u_TileFileNameGM2.pas',
  i_ITileFileNameGeneratorsList in 'i_ITileFileNameGeneratorsList.pas',
  u_TileStorageAbstract in 'u_TileStorageAbstract.pas',
  u_TileStorageGEStuped in 'u_TileStorageGEStuped.pas',
  u_TileStorageFileSystem in 'u_TileStorageFileSystem.pas',
  i_MemCache in 'i_MemCache.pas',
  u_TileFileNameGeneratorsSimpleList in 'u_TileFileNameGeneratorsSimpleList.pas',
  u_TileDownloaderBaseFactory in 'u_TileDownloaderBaseFactory.pas',
  u_GarbageCollectorThread in 'u_GarbageCollectorThread.pas',
  u_ListOfObjectsWithTTL in 'u_ListOfObjectsWithTTL.pas',
  u_PoolElement in 'u_PoolElement.pas',
  u_PoolOfObjectsSimple in 'u_PoolOfObjectsSimple.pas',
  i_IMapCalibration in 'i_IMapCalibration.pas',
  u_MapCalibrationOzi in 'u_MapCalibrationOzi.pas',
  u_MapCalibrationDat in 'u_MapCalibrationDat.pas',
  u_MapCalibrationKml in 'u_MapCalibrationKml.pas',
  u_MapCalibrationTab in 'u_MapCalibrationTab.pas',
  u_MapCalibrationWorldFiles in 'u_MapCalibrationWorldFiles.pas',
  u_MapCalibrationListBasic in 'u_MapCalibrationListBasic.pas',
  i_IAntiBan in 'i_IAntiBan.pas',
  u_AntiBanStuped in 'u_AntiBanStuped.pas',
  i_MapTypes in 'i_MapTypes.pas',
  u_MapTypeBasic in 'u_MapTypeBasic.pas',
  u_MapTypeList in 'u_MapTypeList.pas',
  u_MapTypeListGeneratorFromFullListBasic in 'u_MapTypeListGeneratorFromFullListBasic.pas',
  u_MapTypeListGeneratorFromFullListForMiniMap in 'u_MapTypeListGeneratorFromFullListForMiniMap.pas',
  i_IMapTypeMenuItem in 'i_IMapTypeMenuItem.pas',
  i_IMapTypeMenuItmesList in 'i_IMapTypeMenuItmesList.pas',
  u_MapTypeMenuItemBasic in 'u_MapTypeMenuItemBasic.pas',
  u_MapTypeMenuItmesList in 'u_MapTypeMenuItmesList.pas',
  u_MapTypeMenuItemsGeneratorBasic in 'u_MapTypeMenuItemsGeneratorBasic.pas',
  u_MiniMapMenuItemsFactory in 'u_MiniMapMenuItemsFactory.pas',
  i_IPosChangeMessage in 'i_IPosChangeMessage.pas',
  u_PosChangeMessage in 'u_PosChangeMessage.pas',
  u_MapChangeMessage in 'u_MapChangeMessage.pas',
  i_IMapChangeMessage in 'i_IMapChangeMessage.pas',
  u_HybrChangeMessage in 'u_HybrChangeMessage.pas',
  i_IHybrChangeMessage in 'i_IHybrChangeMessage.pas',
  u_ActiveMapConfig in 'u_ActiveMapConfig.pas',
  u_ActiveMapWithHybrConfig in 'u_ActiveMapWithHybrConfig.pas',
  i_IActiveMapsConfig in 'i_IActiveMapsConfig.pas',
  i_ActiveMapsConfigSaveLoad in 'i_ActiveMapsConfigSaveLoad.pas',
  u_MapsConfigInIniFileSection in 'u_MapsConfigInIniFileSection.pas',
  u_MapViewPortState in 'u_MapViewPortState.pas',
  u_ExportProviderAbstract in 'u_ExportProviderAbstract.pas',
  fr_ExportYaMaps in 'fr_ExportYaMaps.pas' {frExportYaMaps: TFrame},
  u_ExportProviderYaMaps in 'u_ExportProviderYaMaps.pas',
  fr_ExportGEKml in 'fr_ExportGEKml.pas' {frExportGEKml: TFrame},
  u_ExportProviderGEKml in 'u_ExportProviderGEKml.pas',
  fr_ExportIPhone in 'fr_ExportIPhone.pas' {frExportIPhone: TFrame},
  u_ExportProviderIPhone in 'u_ExportProviderIPhone.pas',
  fr_ExportAUX in 'fr_ExportAUX.pas' {frExportAUX: TFrame},
  u_ExportProviderAUX in 'u_ExportProviderAUX.pas',
  fr_ExportToFileCont in 'fr_ExportToFileCont.pas' {frExportToFileCont: TFrame},
  u_ExportProviderZip in 'u_ExportProviderZip.pas',
  Unit1 in 'Unit1.pas' {Fmain},
  Unit2 in 'Unit2.pas' {FGoTo},
  UAbout in 'UAbout.pas' {Fabout},
  Usettings in 'Usettings.pas' {FSettings},
  USaveas in 'USaveas.pas' {Fsaveas},
  UProgress in 'UProgress.pas' {FProgress},
  frm_SearchResults in 'frm_SearchResults.pas' {frmSearchResults},
  UaddPoint in 'UaddPoint.pas' {FaddPoint},
  Unit4 in 'Unit4.pas' {Fprogress2},
  ULogo in 'ULogo.pas' {FLogo},
  USelLonLat in 'USelLonLat.pas' {FSelLonLat},
  Ubrowser in 'Ubrowser.pas' {Fbrowser},
  UaddLine in 'UaddLine.pas' {FaddLine},
  UaddPoly in 'UaddPoly.pas' {FAddPoly},
  UEditMap in 'UEditMap.pas' {FEditMap},
  UMarksExplorer in 'UMarksExplorer.pas' {FMarksExplorer},
  UImport in 'UImport.pas' {FImport},
  UAddCategory in 'UAddCategory.pas' {FAddCategory},
  UFDGAvailablePic in 'UFDGAvailablePic.pas' {FDGAvailablePic},
  UShortcutEditor in 'UShortcutEditor.pas' {FShortcutChange};

{$R *.res} {$R *Pics.res}
begin
  GState := TGlobalState.Create;
  try
    if FileExists(GState.ProgramPath+'SASPlanet.RUS') then begin
      RenameFile(GState.ProgramPath+'SASPlanet.RUS',GState.ProgramPath+'SASPlanet.~RUS');
    end;
    Application.Initialize;
    Application.Title := 'SAS.�������';
    LoadNewResourceModule(GState.Localization);
    //logo
    if GState.MainIni.ReadBool('VIEW','Show_logo',true) then begin
      FLogo:=TFLogo.Create(application);
      FLogo.Label1.Caption:='v '+SASVersion;
      FLogo.Show;
      Application.ProcessMessages;
    end;
    try
      GState.LoadMaps;
      GState.LoadMapIconsList;
    except
      on E: Exception do begin
        Application.ShowException(E);
        Exit;
      end;
    end;
    //xLogo
    Application.HelpFile := '';
    Application.CreateForm(TFmain, Fmain);
  Application.CreateForm(TFGoTo, FGoTo);
  Application.CreateForm(TFabout, Fabout);
  Application.CreateForm(TFSettings, FSettings);
  Application.CreateForm(TFsaveas, Fsaveas);
  Application.CreateForm(TFMarksExplorer, FMarksExplorer);
  Application.CreateForm(TFImport, FImport);
  Application.CreateForm(TFAddCategory, FAddCategory);
  Application.CreateForm(TFDGAvailablePic, FDGAvailablePic);
  Application.CreateForm(TFaddPoint, FaddPoint);
  Application.CreateForm(TFprogress2, Fprogress2);
  Application.CreateForm(TFbrowser, Fbrowser);
  Application.CreateForm(TFaddLine, FaddLine);
  Application.CreateForm(TFAddPoly, FAddPoly);
  Application.CreateForm(TFEditMap, FEditMap);
  Application.CreateForm(TDMMarksDb, DMMarksDb);
  Application.CreateForm(TFShortcutChange, FShortcutChange);
  Fmain.WebBrowser1.Navigate('about:blank');
    Fbrowser.EmbeddedWB1.Navigate('about:blank');
    Application.Run;
  finally
    GState.Free;
  end;
end.
