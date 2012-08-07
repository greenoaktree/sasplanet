unit u_TileProviderWithCache;

interface

uses
  Types,
  i_Bitmap32Static,
  i_VectorDataItemSimple,
  i_CoordConverter,
  i_TileProvider,
  i_TileObjCache;

type
  TBitmapTileProviderWithCache = class(TInterfacedObject, IBitmapTileProvider)
  private
    FSource: IBitmapTileProvider;
    FCache: ITileObjCacheBitmap;
  private
    function GetGeoConverter: ICoordConverter;
    function GetTile(
      const AZoom: Byte;
      const ATile: TPoint
    ): IBitmap32Static;
  public
    constructor Create(
      const ASource: IBitmapTileProvider;
      const ACache: ITileObjCacheBitmap
    );
  end;

  TVectorTileProviderWithCache = class(TInterfacedObject, IVectorTileProvider)
  private
    FSource: IVectorTileProvider;
    FCache: ITileObjCacheVector;
  private
    function GetGeoConverter: ICoordConverter;
    function GetTile(
      const AZoom: Byte;
      const ATile: TPoint
    ): IVectorDataItemList;
  public
    constructor Create(
      const ASource: IVectorTileProvider;
      const ACache: ITileObjCacheVector
    );
  end;

implementation

{ TBitmapTileProviderWithCache }

constructor TBitmapTileProviderWithCache.Create(
  const ASource: IBitmapTileProvider; const ACache: ITileObjCacheBitmap);
begin
  Assert(ASource <> nil);
  Assert(ACache <> nil);
  inherited Create;
  FSource := ASource;
  FCache := ACache;
end;

function TBitmapTileProviderWithCache.GetGeoConverter: ICoordConverter;
begin
  Result := FSource.GeoConverter;
end;

function TBitmapTileProviderWithCache.GetTile(const AZoom: Byte;
  const ATile: TPoint): IBitmap32Static;
begin
  Result := FCache.TryLoadTileFromCache(ATile, AZoom);
  if Result = nil then begin
    Result := FSource.GetTile(AZoom, ATile);
    if Result <> nil then begin
      FCache.AddTileToCache(Result, ATile, AZoom);
    end;
  end;
end;

{ TVectorTileProviderWithCache }

constructor TVectorTileProviderWithCache.Create(
  const ASource: IVectorTileProvider; const ACache: ITileObjCacheVector);
begin
  Assert(ASource <> nil);
  Assert(ACache <> nil);
  inherited Create;
  FSource := ASource;
  FCache := ACache;
end;

function TVectorTileProviderWithCache.GetGeoConverter: ICoordConverter;
begin
  Result := FSource.GeoConverter;
end;

function TVectorTileProviderWithCache.GetTile(const AZoom: Byte;
  const ATile: TPoint): IVectorDataItemList;
begin
  Result := FCache.TryLoadTileFromCache(ATile, AZoom);
  if Result = nil then begin
    Result := FSource.GetTile(AZoom, ATile);
    if Result <> nil then begin
      FCache.AddTileToCache(Result, ATile, AZoom);
    end;
  end;
end;

end.
