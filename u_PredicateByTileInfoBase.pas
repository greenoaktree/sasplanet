unit u_PredicateByTileInfoBase;

interface

uses
  Types,
  i_TileInfoBasic,
  i_PredicateByTileInfo;

type
  TPredicateByTileInfoAbstract = class(TInterfacedObject, IPredicateByTileInfo)
  protected
    function Check(const ATileInfo: ITileInfoBasic; AZoom: Byte; const ATile: TPoint): Boolean; overload;
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; overload; virtual; abstract;
  end;

  TPredicateByTileInfoExistsTile = class(TPredicateByTileInfoAbstract)
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  end;

  TPredicateByTileInfoNotExistsTile = class(TPredicateByTileInfoAbstract)
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  end;

  TPredicateByTileInfoExistsTNE = class(TPredicateByTileInfoAbstract)
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  end;

  TPredicateByTileInfoNotExistsTNE = class(TPredicateByTileInfoAbstract)
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  end;

  TPredicateByTileInfoExistsTileOrTNE = class(TPredicateByTileInfoAbstract)
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  end;

  TPredicateByTileInfoNotExistsTileOrTNE = class(TPredicateByTileInfoAbstract)
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  end;

  TPredicateByTileInfoEqualSize = class(TPredicateByTileInfoAbstract)
  private
    FSize: Cardinal;
    FDeleteTNE: Boolean;
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  public
    constructor Create(ADeleteTNE: Boolean; ASize: Cardinal);
  end;

  TPredicateByTileInfoNotExistOrBeforDate = class(TPredicateByTileInfoAbstract)
  private
    FDate: TDateTime;
    FIgnoreTNE: Boolean;
  protected
    function Check(const ATileInfo: TTileInfo; AZoom: Byte): Boolean; override;
  public
    constructor Create(
      AIgnoreTNE: Boolean;
      const ADate: TDateTime
    );
  end;

implementation

uses
  SysUtils;

{ TPredicateByTileInfoAbstract }

function TPredicateByTileInfoAbstract.Check(
  const ATileInfo: ITileInfoBasic;
  AZoom: Byte;
  const ATile: TPoint
): Boolean;
var
  VTileInfo: TTileInfo;
  VTileWithData: ITileInfoWithData;
begin
  VTileInfo.FTile := ATile;
  if ATileInfo = nil then begin
    VTileInfo.FInfoType := titNotExists;
    VTileInfo.FData := nil;
  end else if ATileInfo.IsExists then begin
    VTileInfo.FInfoType := titExists;
    if Supports(ATileInfo, ITileInfoWithData, VTileWithData) then begin
      VTileInfo.FData := VTileWithData.TileData;
    end else begin
      VTileInfo.FData := nil;
    end;
  end else if ATileInfo.IsExistsTNE then begin
    VTileInfo.FInfoType := titTneExists;
    VTileInfo.FData := nil;
  end else begin
    VTileInfo.FInfoType := titNotExists;
    VTileInfo.FData := nil;
  end;
  VTileInfo.FLoadDate := ATileInfo.LoadDate;
  VTileInfo.FVersionInfo := ATileInfo.VersionInfo;
  VTileInfo.FContentType := ATileInfo.ContentType;
  VTileInfo.FSize := ATileInfo.Size;
  Result := Check(VTileInfo, AZoom);
end;

{ TPredicateByTileInfoEqualSize }

constructor TPredicateByTileInfoEqualSize.Create(ADeleteTNE: Boolean; ASize: Cardinal);
begin
  inherited Create;
  FSize := ASize;
  FDeleteTNE := ADeleteTNE;
end;

function TPredicateByTileInfoEqualSize.Check(
  const ATileInfo: TTileInfo; AZoom: Byte): Boolean;
begin
  Result := False;
  if ATileInfo.FInfoType = titExists then begin
    Result := ATileInfo.FSize = FSize;
  end else if ATileInfo.FInfoType = titTneExists then begin
    Result := FDeleteTNE;
  end;
end;

{ TPredicateByTileInfoExistsTile }

function TPredicateByTileInfoExistsTile.Check(
  const ATileInfo: TTileInfo; AZoom: Byte): Boolean;
begin
  Result := ATileInfo.FInfoType = titExists;
end;

{ TPredicateByTileInfoExistsTNE }

function TPredicateByTileInfoExistsTNE.Check(
  const ATileInfo: TTileInfo; AZoom: Byte): Boolean;
begin
  Result := ATileInfo.FInfoType = titTneExists;
end;

{ TPredicateByTileInfoExistsTileOrTNE }

function TPredicateByTileInfoExistsTileOrTNE.Check(
  const ATileInfo: TTileInfo; AZoom: Byte): Boolean;
begin
  Result := (ATileInfo.FInfoType = titTneExists) or (ATileInfo.FInfoType = titExists);
end;

{ TPredicateByTileInfoNotExistsTile }

function TPredicateByTileInfoNotExistsTile.Check(
  const ATileInfo: TTileInfo; AZoom: Byte): Boolean;
begin
  Result := ATileInfo.FInfoType <> titExists;
end;

{ TPredicateByTileInfoNotExistsTNE }

function TPredicateByTileInfoNotExistsTNE.Check(
  const ATileInfo: TTileInfo; AZoom: Byte): Boolean;
begin
  Result := ATileInfo.FInfoType <> titTneExists;
end;

{ TPredicateByTileInfoNotExistsTileOrTNE }

function TPredicateByTileInfoNotExistsTileOrTNE.Check(
  const ATileInfo: TTileInfo; AZoom: Byte): Boolean;
begin
  Result := (ATileInfo.FInfoType <> titTneExists) and (ATileInfo.FInfoType <> titExists);
end;

{ TPredicateByTileInfoBeforDate }

constructor TPredicateByTileInfoNotExistOrBeforDate.Create(
  AIgnoreTNE: Boolean;
  const ADate: TDateTime
);
begin
  inherited Create;
  FDate := ADate;
  FIgnoreTNE := AIgnoreTNE;
end;

function TPredicateByTileInfoNotExistOrBeforDate.Check(
  const ATileInfo: TTileInfo; AZoom: Byte
): Boolean;
begin
  if ATileInfo.FInfoType = titNotExists then begin
    Result := True;
  end else if (ATileInfo.FInfoType = titTneExists) and FIgnoreTNE then begin
    Result := True;
  end else if (ATileInfo.FInfoType = titExists) and (ATileInfo.FLoadDate < FDate) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

end.