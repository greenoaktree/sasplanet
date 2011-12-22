unit u_ThreadMapCombineJPG;

interface

uses
  Windows,
  Types,
  SysUtils,
  Classes,
  GR32,
  i_GlobalViewMainConfig,
  i_BitmapLayerProvider,
  i_LocalCoordConverterFactorySimpe,
  u_MapType,
  u_GeoFun,
  u_BmpUtil,
  t_GeoTypes,
  i_BitmapPostProcessingConfig,
  u_ResStrings,
  u_ThreadMapCombineBase,
  libJPEG;

type
  TThreadMapCombineJPG = class(TThreadMapCombineBase)
  private
    FQuality: Integer;
  protected
    procedure saveRECT; override;
  public
    constructor Create(
      AViewConfig: IGlobalViewMainConfig;
      AMarksImageProvider: IBitmapLayerProvider;
      ALocalConverterFactory: ILocalCoordConverterFactorySimpe;
      AMapCalibrationList: IInterfaceList;
      AFileName: string;
      APolygon: TArrayOfDoublePoint;
      ASplitCount: TPoint;
      Azoom: byte;
      Atypemap: TMapType;
      AHtypemap: TMapType;
      AusedReColor: Boolean;
      ARecolorConfig: IBitmapPostProcessingConfigStatic;
      AQuality: Integer
    );
  end;

implementation

uses
  i_LocalCoordConverter;

type
  my_dest_mgr_ptr = ^my_dest_mgr;
  my_dest_mgr = record
    pub: jpeg_destination_mgr;
    DestStream: TStream;
    DestBuffer: array [1..4096] of byte;
  end;

procedure error_exit(cinfo: j_common_ptr); cdecl; forward;
procedure output_message(cinfo: j_common_ptr); cdecl; forward;
procedure init_destination(cinfo: j_compress_ptr); cdecl; forward;
function empty_output_buffer(cinfo: j_compress_ptr): boolean; cdecl; forward;
procedure term_destination(cinfo: j_compress_ptr); cdecl; forward;

{ TThreadMapCombineJPG }

constructor TThreadMapCombineJPG.Create(
  AViewConfig: IGlobalViewMainConfig;
  AMarksImageProvider: IBitmapLayerProvider;
  ALocalConverterFactory: ILocalCoordConverterFactorySimpe;
  AMapCalibrationList: IInterfaceList;
  AFileName: string;
  APolygon: TArrayOfDoublePoint;
  ASplitCount: TPoint;
  Azoom: byte;
  Atypemap, AHtypemap: TMapType;
  AusedReColor: Boolean;
  ARecolorConfig: IBitmapPostProcessingConfigStatic;
  AQuality: Integer
);
begin
  inherited Create(
    AViewConfig,
    AMarksImageProvider,
    ALocalConverterFactory,
    AMapCalibrationList,
    AFileName,
    APolygon,
    ASplitCount,
    Azoom,
    Atypemap,
    AHtypemap,
    AusedReColor,
    ARecolorConfig
  );
  FQuality := AQuality;
end;

procedure TThreadMapCombineJPG.saveRECT;
var
  iWidth, iHeight: integer;
  i,j: integer;
  jpeg: jpeg_compress_struct;
  jpeg_err: jpeg_error_mgr;
  prow: JSAMPROW;
  VComment: string;
  VStream: TFileStream;
  SwapBuf: Byte;
begin
  sx := (FCurrentPieceRect.Left mod 256);
  sy := (FCurrentPieceRect.Top mod 256);
  ex := (FCurrentPieceRect.Right mod 256);
  ey := (FCurrentPieceRect.Bottom mod 256);

  iWidth := FMapPieceSize.X;
  iHeight := FMapPieceSize.y;

  if (iWidth >= 65500) or (iHeight >= 65500) then begin
    raise Exception.Create(
      'Selected resolution is too big for JPEG format!'+#13#10+
      'Widht = '+inttostr(iWidth) + ' (max = 65500)' + #13#10+
      'Height = '+inttostr(iHeight) + ' (max = 65500)' + #13#10+
      'Try select smaller region to stitch in JPEG or select other output format (ECW is the best).'
    );
  end;

  if not init_libJPEG then begin
    raise Exception.Create('Initialization of libJPEG failed.');
  end;

  VStream := TFileStream.Create(FCurrentFileName, fmCreate);

  try
    FillChar(jpeg, SizeOf(jpeg_compress_struct), $00);
    FillChar(jpeg_err, SizeOf(jpeg_error_mgr), $00);

    // error managment
    jpeg.err := jpeg_std_error(@jpeg_err);
    jpeg_err.error_exit := error_exit;
    jpeg_err.output_message := output_message;

    // compression struct
    jpeg_create_compress(@jpeg);
    try
      if jpeg.dest = nil then begin

        // allocation space for streaming methods
        jpeg.dest := jpeg.mem^.alloc_small(@jpeg, JPOOL_PERMANENT, SizeOf(my_dest_mgr));

        // seeting up custom functions
        with my_dest_mgr_ptr(jpeg.dest)^ do begin
          pub.init_destination    := init_destination;
          pub.empty_output_buffer := empty_output_buffer;
          pub.term_destination    := term_destination;

          pub.next_output_byte    := @DestBuffer[1];
          pub.free_in_buffer      := Length(DestBuffer);

          DestStream := VStream;
        end;
      end;

      // very important state
      jpeg.global_state := CSTATE_START;

      jpeg.image_width := iWidth;
      jpeg.image_height := iHeight;
      jpeg.input_components := 3;
      jpeg.in_color_space := JCS_RGB;

      // setting defaults
      jpeg_set_defaults(@jpeg);

      // compression quality
      jpeg_set_quality(@jpeg, FQuality, True);

      // start compression
      jpeg_start_compress(@jpeg, true);

      // write marker (comment)
      VComment := 'Created with SAS.Planet and libjpeg-turbo' + #0;
      jpeg_write_marker(@jpeg, JPEG_COM, @VComment[1], length(VComment));

      // allocate row
      GetMem(prow, jpeg.image_width * 3);

      GetMem(FArray256BGR, 256 * sizeof(P256ArrayBGR));
      for i := 0 to 255 do begin
        GetMem(FArray256BGR[i], (iWidth + 1) * 3);
      end;
      try
        btmm := TCustomBitmap32.Create;
        try
          btmm.Width := 256;
          btmm.Height := 256;

          for i := 0 to jpeg.image_height - 1 do begin

            if jpeg.global_state = 0 then begin
              Break;
            end;

            ReadLine(i, prow);

            // BGR to RGB swap
            for j := 0 to jpeg.image_width - 1 do begin
              SwapBuf := PByte(Integer(prow) + j*3)^;
              PByte(Integer(prow) + j*3)^ := PByte(Integer(prow) + j*3 + 2)^;
              PByte(Integer(prow) + j*3 + 2)^ := SwapBuf;
            end;

            // write row
            jpeg_write_scanlines(@jpeg, @prow, 1);

            if CancelNotifier.IsOperationCanceled(OperationID) then begin
              Break;
            end;
          end;
        finally
          btmm.Free;
        end;
      finally
        for i := 0 to 255 do begin
          freemem(FArray256BGR[i], (iWidth + 1) * 3);
        end;
        freemem(FArray256BGR, 256 * ((iWidth + 1) * 3));

        // freeing row
        FreeMem(prow);
      end;
    finally
      if jpeg.global_state <> 0 then begin
        // finish compression
        jpeg_finish_compress(@jpeg);
      end;

      // destroy compression
      jpeg_destroy_compress(@jpeg);
    end;
  finally
    VStream.Free;
  end;
end;

procedure error_exit(cinfo: j_common_ptr);
var
  Msg: String;
  ErrCode: Integer;
begin
  SetLength(Msg, 256);
  cinfo^.err^.format_message(cinfo, PChar(Msg));
  ErrCode := cinfo^.err^.msg_code;
  cinfo^.global_state := 0;
  jpeg_abort(cinfo);
  raise Exception.Create('LibJPEG: ERROR [' + IntToStr(ErrCode) + '] ' + PChar(Msg) );
end;

procedure output_message(cinfo: j_common_ptr);
var
  Msg: String;
  ErrCode: Integer;
begin
  SetLength(Msg, 256);
  cinfo^.err^.format_message(cinfo, PChar(Msg));
  ErrCode := cinfo^.err^.msg_code;
  cinfo^.global_state := 0;
  raise Exception.Create('LibJPEG: OUTPUT [' + IntToStr(ErrCode) + '] ' + PChar(Msg) );
end;

procedure init_destination(cinfo: j_compress_ptr);
begin
//
end;

function empty_output_buffer(cinfo: j_compress_ptr): boolean;
var
  dest: my_dest_mgr_ptr;
begin
  dest := my_dest_mgr_ptr(cinfo^.dest);
  if dest^.pub.free_in_buffer < Cardinal(Length(dest^.DestBuffer)) then begin
    // write complete buffer
    dest^.DestStream.Write(dest^.DestBuffer[1], SizeOf(dest^.DestBuffer));
    // reset buffer
    dest^.pub.next_output_byte := @dest^.DestBuffer[1];
    dest^.pub.free_in_buffer := Length(dest^.DestBuffer);
  end;
  Result := True;
end;

procedure term_destination(cinfo: j_compress_ptr);
var
  Idx: Integer;
  dest: my_dest_mgr_ptr;
begin
  dest := my_dest_mgr_ptr(cinfo^.dest);
  for Idx := low(dest^.DestBuffer) to High(dest^.DestBuffer) do begin
    // check for endblock
    if (dest^.DestBuffer[Idx] = $FF) and (dest^.DestBuffer[Idx +1] = JPEG_EOI) then begin
      // write endblock
      dest^.DestStream.Write(dest^.DestBuffer[Idx], 2);
      // leave
      Break;
    end else begin
      dest^.DestStream.Write(dest^.DestBuffer[Idx], 1);
    end;
  end;
end;

end.
