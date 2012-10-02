unit u_TileRequestTask;

interface

uses
  SysUtils,
  i_NotifierOperation,
  i_TileRequest,
  i_TileRequestResult,
  i_TileRequestTask;

type
  TTileRequestTask = class(TInterfacedObject, ITileRequestTask, ITileRequestTaskInternal)
  private
    FSync: IReadWriteSync;
    FTileRequest: ITileRequest;
    FCancelNotifier: INotifierOneOperation;

    FResult: ITileRequestResult;
    FFinishNotifier: INotifierOneOperation;
    FFinishNotifierInternal: INotifierOneOperationInternal;
  private
    function GetTileRequest: ITileRequest;
    function GetCancelNotifier: INotifierOneOperation;
    function GetResult: ITileRequestResult;
    function GetFinishNotifier: INotifierOneOperation;
  private
    procedure SetFinished(AResult: ITileRequestResult);
  public
    constructor Create(
      ATileRequest: ITileRequest;
      ACancelNotifier: INotifierOneOperation;
      ASync: IReadWriteSync
    );

  end;


implementation

uses
  u_NotifierOperation;

{ TTileRequestTask }

constructor TTileRequestTask.Create(
  ATileRequest: ITileRequest;
  ACancelNotifier: INotifierOneOperation;
  ASync: IReadWriteSync
);
begin
  inherited Create;
  FSync := ASync;
  FTileRequest := ATileRequest;
  FCancelNotifier := ACancelNotifier;

  FResult := nil;
  FFinishNotifierInternal := TNotifierOneOperation.Create;
  FFinishNotifier := FFinishNotifierInternal;
end;

function TTileRequestTask.GetCancelNotifier: INotifierOneOperation;
begin
  Result := FCancelNotifier;
end;

function TTileRequestTask.GetFinishNotifier: INotifierOneOperation;
begin
  Result := FFinishNotifier;
end;

function TTileRequestTask.GetResult: ITileRequestResult;
begin
  FSync.BeginRead;
  try
    Result := FResult;
  finally
    FSync.EndRead;
  end;
end;

function TTileRequestTask.GetTileRequest: ITileRequest;
begin
  Result := FTileRequest;
end;

procedure TTileRequestTask.SetFinished(AResult: ITileRequestResult);
begin
  FSync.BeginWrite;
  try
    FResult := AResult;
  finally
    FSync.EndWrite;
  end;
  FFinishNotifierInternal.ExecuteOperation(Self);
end;

end.