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

unit i_TileDownloadRequestBuilderConfig;

interface

uses
  i_ConfigDataElement,
  i_CoordConverter;

type
  ITileDownloadRequestBuilderConfigStatic = interface
    ['{84B1A72C-951D-4591-80E4-3DA0CDC30ED7}']
    function  GetUrlBase: string;
    property UrlBase: string read GetUrlBase;

    function  GetRequestHeader: string;
    property RequestHeader: string read GetRequestHeader;

    function GetGeoCoder: ICoordConverter;
    property GeoCoder: ICoordConverter read GetGeoCoder;
  end;


  ITileDownloadRequestBuilderConfig = interface(IConfigDataElement)
    ['{FA554C29-EDAF-4E3C-9B59-BC881502F33A}']
    function  GetUrlBase: string;
    procedure SetUrlBase(AValue: string);
    property UrlBase: string read GetUrlBase write SetUrlBase;

    function  GetRequestHeader: string;
    procedure SetRequestHeader(AValue: string);
    property RequestHeader: string read GetRequestHeader write SetRequestHeader;

    function GetGeoCoder: ICoordConverter;
    property GeoCoder: ICoordConverter read GetGeoCoder;
  end;

implementation

end.
