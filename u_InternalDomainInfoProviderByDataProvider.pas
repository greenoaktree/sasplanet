unit u_InternalDomainInfoProviderByDataProvider;

interface

uses
  i_BinaryData,
  i_ConfigDataProvider,
  i_ContentTypeManager,
  i_InternalDomainInfoProvider;

type
  TInternalDomainInfoProviderByDataProvider = class(TInterfacedObject, IInternalDomainInfoProvider)
  private
    FContentTypeManager: IContentTypeManager;
    FProvider: IConfigDataProvider;

    function LoadDataFromSubDataProvider(ADataProvider: IConfigDataProvider; AFileName: string; out AContentType: string): IBinaryData;
    function LoadDataFromDataProvider(ADataProvider: IConfigDataProvider; AFileName: string; out AContentType: string): IBinaryData;
  private
    function LoadBinaryByFilePath(AFilePath: string; out AContentType: string): IBinaryData;
  public
    constructor Create(
      AProvider: IConfigDataProvider;
      AContentTypeManager: IContentTypeManager
    );
  end;

implementation


uses
  StrUtils,
  SysUtils,
  i_ContentTypeInfo;

const
  CFileNameSeparator = '/';

{ TInternalDomainInfoProviderByDataProvider }

constructor TInternalDomainInfoProviderByDataProvider.Create(
  AProvider: IConfigDataProvider;
  AContentTypeManager: IContentTypeManager
);
begin
  FProvider := AProvider;
  FContentTypeManager := AContentTypeManager;
end;

function TInternalDomainInfoProviderByDataProvider.LoadBinaryByFilePath(
  AFilePath: string; out AContentType: string): IBinaryData;
begin
  Result := LoadDataFromSubDataProvider(FProvider, AFilePath, AContentType);
end;

function TInternalDomainInfoProviderByDataProvider.LoadDataFromDataProvider(
  ADataProvider: IConfigDataProvider; AFileName: string;
  out AContentType: string): IBinaryData;
var
  VFileName: string;
  VExt: string;
  VContentType: IContentTypeInfoBasic;
begin
  AContentType := '';
  VFileName := AFileName;
  if VFileName = '' then begin
    VFileName := 'index.html';
  end;
  if AContentType = '' then begin
    VExt := ExtractFileExt(VFileName);
    VContentType := FContentTypeManager.GetInfoByExt(VExt);
    if VContentType <> nil then begin
      AContentType := VContentType.GetContentType;
    end else begin
      AContentType := 'text/html'
    end;
  end;

  Result := ADataProvider.ReadBinary(VFileName);
end;

function TInternalDomainInfoProviderByDataProvider.LoadDataFromSubDataProvider(
  ADataProvider: IConfigDataProvider;
  AFileName: string;
  out AContentType: string
): IBinaryData;
var
  VSubItemName: string;
  VFileName: string;
  VPos: Integer;
  VSubItemProvider: IConfigDataProvider;
begin
  VSubItemName := '';
  VFileName := '';
  VPos := Pos(CFileNameSeparator, AFileName);
  if VPos > 0 then begin
    VSubItemName := LeftStr(AFileName, VPos - 1);
    VFileName := RightStr(AFileName, Length(AFileName) - VPos - Length(CFileNameSeparator) + 1);
    if VSubItemName <> '' then begin
      VSubItemProvider := ADataProvider.GetSubItem(VSubItemName);
    end else begin
      VSubItemProvider := ADataProvider;
    end;
    if VSubItemProvider <> nil then begin
      Result := LoadDataFromSubDataProvider(VSubItemProvider, VFileName, AContentType);
    end else begin
      Result := nil;
    end;
  end else begin
    VFileName := AFileName;
    Result := LoadDataFromDataProvider(ADataProvider, VFileName, AContentType);
  end;
end;

end.