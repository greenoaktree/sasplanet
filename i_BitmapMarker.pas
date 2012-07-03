{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2012, SAS.Planet development team.                      *}
{* This program is free software: you can redistribute it and/or modify       *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* This program is distributed in the hope that it will be useful,            *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with this program.  If not, see <http://www.gnu.org/licenses/>.      *}
{*                                                                            *}
{* http://sasgis.ru                                                           *}
{* az@sasgis.ru                                                               *}
{******************************************************************************}

unit i_BitmapMarker;

interface

uses
  GR32,
  i_Notifier, 
  t_GeoTypes,
  i_Bitmap32Static;

type
  IBitmapMarker = interface(IBitmap32Static)
    ['{03AB4233-EEEA-4AD6-A194-EFD32345056D}']
    function GetBitmapSize: TPoint;
    property BitmapSize: TPoint read GetBitmapSize;

    function GetAnchorPoint: TDoublePoint;
    property AnchorPoint: TDoublePoint read GetAnchorPoint;
  end;

  IBitmapMarkerWithDirection = interface(IBitmapMarker)
    ['{A27674DB-F074-4E54-8BBA-DF29972191BF}']
    function GetDirection: Double;
    property Direction: Double read GetDirection;
  end;

  IBitmapMarkerProvider = interface
    ['{A186F046-0CFB-456A-A6C3-271046CB2CA0}']
    function GetMarker: IBitmapMarker;
    function GetMarkerBySize(ASize: Integer): IBitmapMarker;
  end;

  IBitmapMarkerWithDirectionProvider = interface(IBitmapMarkerProvider)
    ['{80B3D3EB-E42E-4D40-A20D-6C15F7E446A0}']
    function GetMarkerWithRotation(const AAngle: Double): IBitmapMarkerWithDirection;
    function GetMarkerWithRotationBySize(
      const AAngle: Double;
      ASize: Integer
    ): IBitmapMarkerWithDirection;
  end;

  IBitmapMarkerProviderChangeable = interface
    ['{A81C1CCD-76B8-48F7-8079-25F1D1A8D10B}']
    function GetStatic: IBitmapMarkerProvider;

    function GetChangeNotifier: INotifier;
    property ChangeNotifier: INotifier read GetChangeNotifier;
  end;

implementation

end.


