unit i_ILocalCoordConverter;

interface

uses
  Types,
  t_GeoTypes,
  i_ICoordConverter;

type
  ILocalCoordConverter = interface
    ['{48CD8E96-6EB3-4162-B321-B8B64D71B0AB}']
    function GetZoom: Byte;
    function GetGeoConverter: ICoordConverter;
    function LocalPixel2MapPixel(const APoint: TPoint): TPoint;
    function LocalPixel2MapPixelFloat(const APoint: TPoint): TDoublePoint;
    function LocalPixelFloat2MapPixelFloat(const APoint: TDoublePoint): TDoublePoint;
    function MapPixel2LocalPixel(const APoint: TPoint): TPoint;
    function MapPixel2LocalPixelFloat(const APoint: TPoint): TDoublePoint;
    function MapPixelFloat2LocalPixelFloat(const APoint: TDoublePoint): TDoublePoint;

    function LocalRect2MapRect(const ARect: TRect): TRect;
    function LocalRect2MapRectFloat(const ARect: TRect): TDoubleRect;
    function LocalRectFloat2MapRectFloat(const ARect: TDoubleRect): TDoubleRect;
    function MapRect2LocalRect(const ARect: TRect): TRect;
    function MapRect2LocalRectFloat(const ARect: TRect): TDoubleRect;
    function MapRectFloat2LocalRectFloat(const ARect: TDoubleRect): TDoubleRect;

    function LocalPixel2LonLat(const APoint: TPoint): TDoublePoint;
    function LocalPixelFloat2LonLat(const APoint: TDoublePoint): TDoublePoint;
    function LonLat2LocalPixel(const APoint: TDoublePoint): TPoint;
    function LonLat2LocalPixelFloat(const APoint: TDoublePoint): TDoublePoint;
  end;

implementation

end.
