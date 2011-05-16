unit u_TileDownloaderBaseCore;

interface

uses
  Windows,
  Classes,
  SysUtils,
  i_ConfigDataProvider,
  i_RequestBuilderScript,
  i_TileDownloader,
  u_RequestBuilderScript,
  u_RequestBuilderPascalScript,
  u_TileDownloader,
  u_TileDownloaderBaseThread;

type
  TTileDownloaderBaseCore = class(TTileDownloader)
  private
    FSemaphore: THandle;
    FDownloadesList: TList;
    FRawResponseHeader: string;
    function GetRequestBuilderScript(AConfig: IConfigDataProvider): IRequestBuilderScript;
    function GetConfigDataProvider: IConfigDataProvider;
    function TryGetDownloadThread: TTileDownloaderBaseThread;
  public
    constructor Create(AConfig: IConfigDataProvider; AZmpFileName: string);
    destructor Destroy; override;
    procedure Download(AEvent: ITileDownloaderEvent); override;
    procedure OnTileDownload(AEvent: ITileDownloaderEvent);
  end;

implementation

uses
  Dialogs,
  u_ConfigDataProviderByKaZip,
  u_ConfigDataProviderByFolder,
  u_ResStrings;

{ TTileDownloaderBaseCore }

constructor TTileDownloaderBaseCore.Create(AConfig: IConfigDataProvider; AZmpFileName: string);
begin
  inherited Create(AConfig, AZmpFileName);
  FRequestBuilderScript := GetRequestBuilderScript(AConfig);
  //FRequestBuilderScript := GetRequestBuilderScript(GetConfigDataProvider);
  FSemaphore := CreateSemaphore(nil, FMaxConnectToServerCount, FMaxConnectToServerCount, nil);
  FDownloadesList := TList.Create;
end;

destructor TTileDownloaderBaseCore.Destroy;
var
  I: Integer;
  VDwnThr: TTileDownloaderBaseThread;
begin
  try
    for I := 0 to FDownloadesList.Count - 1 do
    try
      VDwnThr := FDownloadesList.Items[I];
      if Assigned(VDwnThr) then
        VDwnThr.Terminate;
    except
    end;
    FDownloadesList.Clear;
    FreeAndNil(FDownloadesList);
  finally
    FSemaphore := 0;
    inherited Destroy;
  end;
end;

function TTileDownloaderBaseCore.GetRequestBuilderScript(AConfig: IConfigDataProvider): IRequestBuilderScript;
begin
  try
    Result := TRequestBuilderPascalScript.Create(AConfig);
    FEnabled := True;
  except
    on E: Exception do
    begin
      Result := nil;
      ShowMessageFmt(SAS_ERR_UrlScriptError, [FMapName, E.Message, FZmpFileName]);
    end;
  else
    Result := nil;
    ShowMessageFmt(SAS_ERR_UrlScriptUnexpectedError, [FMapName, FZmpFileName]);
  end;
  if Result = nil then
  begin
    FEnabled := False;
    Result := TRequestBuilderScript.Create(AConfig);
  end;
end;

function TTileDownloaderBaseCore.GetConfigDataProvider: IConfigDataProvider;
begin
  try
    Result := nil;
    if FileExists(FZmpFileName) then
      Result := TConfigDataProviderByKaZip.Create(FZmpFileName)
    else
      Result := TConfigDataProviderByFolder.Create(FZmpFileName);
  except
    Result := nil;
  end;
end;

function TTileDownloaderBaseCore.TryGetDownloadThread: TTileDownloaderBaseThread;
var
  I: Integer;
  VConfig: IConfigDataProvider;
begin
  Result := nil;
  if WaitForSingleObject(FSemaphore, FTimeOut) = WAIT_OBJECT_0  then
  begin
    Lock;
    try
      for I := 0 to FDownloadesList.Count - 1 do
      try
        Result := FDownloadesList.Items[I];
        if Assigned(Result) then
        begin
          if Result.Busy then
            Result := nil
          else
            Break;
        end;
      except
        Result := nil;
      end;
      if not Assigned(Result) and (FDownloadesList.Count < integer(FMaxConnectToServerCount)) then
      begin

        Result := TTileDownloaderBaseThread.Create;
        Result.RequestBuilderScript := FRequestBuilderScript;
        FDownloadesList.Add(Result);

        {
        VConfig := GetConfigDataProvider;
        if VConfig <> nil then
        begin
          Result := TTileDownloaderBaseThread.Create;
          Result.RequestBuilderScript := GetRequestBuilderScript(VConfig);
          FDownloadesList.Add(Result);
        end;
        }
      end;
    finally
      UnLock;
    end;
  end;
end;

procedure TTileDownloaderBaseCore.Download(AEvent: ITileDownloaderEvent);
var
  VDwnThr: TTileDownloaderBaseThread;
begin
  VDwnThr := TryGetDownloadThread;
  if Assigned(VDwnThr) then
  begin
    Lock;
    try
      AEvent.AddToCallBackList(OnTileDownload);
      VDwnThr.TimeOut := FTimeOut;
      VDwnThr.RawResponseHeader := FRawResponseHeader;
      VDwnThr.Semaphore := FSemaphore;
      VDwnThr.AddEvent(AEvent);
    finally
      UnLock;
    end;
  end
  else
    AEvent.ErrorString := 'No free connections!';
end;

procedure TTileDownloaderBaseCore.OnTileDownload(AEvent: ITileDownloaderEvent);
begin
  Lock;
  try
    if Assigned(AEvent) then
    begin
      FRawResponseHeader := AEvent.RawResponseHeader;
    end;
  finally
    Unlock;
  end;
end;

end.
