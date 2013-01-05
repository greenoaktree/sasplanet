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

unit i_NotifierTTLCheck;

interface

uses
  i_ListenerTTLCheck;

type
  INotifierTime = interface
    ['{91D40422-C434-43B0-8C5A-D7F774C51773}']
    procedure Add(const AListener: IListenerTime);
    procedure Remove(const AListener: IListenerTime);
  end;

  INotifierTimeInternal = interface(INotifierTime)
    procedure Notify(const ANow: Cardinal);
  end;

  INotifierTTLCheck = interface
    ['{25465366-07F9-459A-9D54-1597E4BD6306}']
    procedure Add(const AListener: IListenerTTLCheck);
    procedure Remove(const AListener: IListenerTTLCheck);
  end;

  INotifierTTLCheckInternal = interface(INotifierTTLCheck)
    function ProcessCheckAndGetNextTime: Cardinal;
  end;

implementation

end.

