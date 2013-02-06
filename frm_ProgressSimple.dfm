object frmProgressSimple: TfrmProgressSimple
  Left = 207
  Top = 161
  BorderStyle = bsToolWindow
  BorderWidth = 3
  Caption = 'Please wait...'
  ClientHeight = 44
  ClientWidth = 319
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  PopupMode = pmExplicit
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton_fit: TSpeedButton
    Left = 291
    Top = 0
    Width = 28
    Height = 28
    Hint = 'Fit to Screen'
    Align = alRight
    Flat = True
    Glyph.Data = {
      06030000424D060300000000000036000000280000000F0000000F0000000100
      180000000000D002000000000000000000000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF88B2
      CB337CA9AFD2E8000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF88B2CB4386AF8EC1E3367CA8000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8BB4CD4386AF8EC1
      E34989B293B8D0000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFF92B8D04486B08EC1E34989B293B8D0FFFFFF000000FFFFFFFFFFFF
      FFFFFFBDBEBE828584606462828584BDBEBEFFFFFF2E77A482B7D94889B291B7
      CFFFFFFFFFFFFF000000FFFFFFFFFFFF8082818A8D8CDBD9D6EFEAE5D9D7D28A
      8B898082817A99AB3178A693B8D0FFFFFFFFFFFFFFFFFF000000FFFFFF808281
      BCBEBCF7F0EAEFE0D2F0E1D3F4E8DEF8F2EDBAB8B5808280FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFF000000BDBEBE8A8D8CF8F2EBBE753CBE753CEFDECFBE753CBE
      753CF9F3EE8A8B89BDBEBEFFFFFFFFFFFFFFFFFFFFFFFF000000828584DCDCDA
      ECD9C6BE753CEBD8C5EEDFD0F0E2D4BE753CF6EDE5D9D6D2828482FFFFFFFFFF
      FFFFFFFFFFFFFF000000606462F1EEEAE8D1BBE8D4C2EBDACAEEE0D3EFE3D8F2
      E5D9F5EAE0F1EDE9616462FFFFFFFFFFFFFFFFFFFFFFFF000000828483DCDBD9
      ECDAC9BE753CEBE0D4EEE5DCEEE7E0BE753CF7EEE6DAD8D4818381FFFFFFFFFF
      FFFFFFFFFFFFFF000000BCBDBC8D908EF6EEE6CF9F72CF9F72EEE7E0BE753CBE
      753CF9F4EF8B8C8ABBBCBCFFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFF7D817F
      C0C0BEF6EDE4F1E2D5F1E3D7F5EAE1F9F3EEBDBCB87D807EFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFF000000FFFFFFFFFFFF7E81808E918FDDD9D5F1ECE6DDD9D48E
      8F8B7E817EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFF
      FFFFFFB9BABA828584606462828584B9BABAFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFF000000}
    Layout = blGlyphTop
    Margin = 5
    ParentShowHint = False
    ShowHint = True
    OnClick = SpeedButton_fitClick
  end
  object SpeedButton_selmanager: TSpeedButton
    Left = 263
    Top = 0
    Width = 28
    Height = 28
    Hint = 'Selection Manager'
    Align = alRight
    Flat = True
    Glyph.Data = {
      26040000424D2604000000000000360000002800000012000000120000000100
      180000000000F003000000000000000000000000000000000000FFFFFFFFA41C
      FFD494FFD18BFFFFFFFFD18BFFD18BFFFFFFFF9900FFA722FFFFFFFFD18BFFD1
      8BFFFFFFFFD18BFFD08AFFA41CFEAF390000FFA318FF9900FFBD5BFFBE5CFFFF
      FFFFBE5CFFBE5CFFFFFFFEA41BFFB03AFFFFFFFFBE5CFFBE5CFFFFFFFFBE5CFF
      BB54FF9900FAA0170000FFD18BFFBE5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBA53FFD18B
      0000FFD18BFFBE5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBE5CFFD18B0000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFD18BFFBE5CFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFBE5CFFD18B0000FFD18BFFBE5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBE5CFFD18B
      0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FF9900FFA722
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF9900FFA7220000FEA41BFFB03AFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFEA41BFFB03A0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      0000FFD18BF9D39CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBE5CFFD18B0000FFD18BF9D39C
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFBE5CFFD18B0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF0000FFD18BFFBE5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBE5CFFEFD7
      0000FFD18BFFBE5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBA53FFD6980000FFA318FF9900
      FFBD5BFFBE5CFFFFFFFFBE5CFFBE5CFFFFFFFF9900FFA722FFFFFFFFBE5CFFBE
      5CFFFFFFFFBE5CFFBB54FF9900FFA7220000FFAD31FFA41CFFD494FFD18BFFFF
      FFFFD18BFFD18BFFFFFFFEA41BFFB03AFFFFFFFFD18BFFD18BFFFFFFFFD18BFF
      D089FEA41BFFB03A0000}
    Layout = blGlyphTop
    Margin = 5
    ParentShowHint = False
    ShowHint = True
    OnClick = SpeedButton_selmanagerClick
  end
  object MemoInfo: TMemo
    Left = 0
    Top = 0
    Width = 263
    Height = 28
    Align = alClient
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      '')
    ReadOnly = True
    TabOrder = 0
    OnChange = MemoInfoChange
    ExplicitLeft = -6
    ExplicitTop = -6
  end
  object pnlProgress: TPanel
    Left = 0
    Top = 28
    Width = 319
    Height = 16
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
  end
end
