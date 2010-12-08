unit u_MapTypeList;

interface

uses
  ActiveX,
  i_IGUIDList,
  i_MapTypes;

type
  TMapTypeList = class(TInterfacedObject, IMapTypeList)
  private
    FList: IGUIDInterfaceList;
    function GetMapTypeByGUID(AGUID: TGUID): IMapType;
    function GetIterator: IEnumGUID;
  public
    procedure Add(AMap: IMapType);
    constructor Create(AAllowNil: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  u_GUIDInterfaceList,
  c_ZeroGUID;

{ TMapTypeList }

procedure TMapTypeList.Add(AMap: IMapType);
var
  VGUID: TGUID;
begin
  if AMap <> nil then begin
    VGUID := AMap.GetMapType.GUID;
  end else begin
    VGUID := CGUID_Zero;
  end;
  FList.Add(AMap.GetMapType.GUID, AMap);
end;

constructor TMapTypeList.Create(AAllowNil: Boolean);
begin
  FList := TGUIDInterfaceList.Create(AAllowNil);
end;

destructor TMapTypeList.Destroy;
begin
  FList := nil;
  inherited;
end;

function TMapTypeList.GetIterator: IEnumGUID;
begin
  Result := FList.GetGUIDEnum;
end;

function TMapTypeList.GetMapTypeByGUID(AGUID: TGUID): IMapType;
begin
  Result := Flist.GetByGUID(AGUID) as IMapType;
end;

end.
