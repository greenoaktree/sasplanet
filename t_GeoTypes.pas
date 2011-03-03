unit t_GeoTypes;

interface

uses
  Types;

type
  TDoublePoint = record
    X, Y: Double;
  end;

  TDoubleRect = packed record
    case Integer of
      0: (Left, Top: Double;
        Right, Bottom: Double);
      1: (TopLeft, BottomRight: TDoublePoint);
  end;

  TArrayOfPoint = array of TPoint;

  TArrayOfDoublePoint = array of TDoublePoint;

// ���������� �� ECWReader ��� �� �� ��������� ������ ����������� �� ���� �����.
{$MINENUMSIZE 4}
type
  TCellSizeUnits =
    (
    // Invalid cell units
    CELL_UNITS_INVALID = 0,
    // Cell units are standard meters
    CELL_UNITS_METERS = 1,
    // Degrees
    CELL_UNITS_DEGREES = 2,
    // US Survey feet
    CELL_UNITS_FEET = 3,
    // Unknown cell units
    CELL_UNITS_UNKNOWN = 4
    );

implementation

end.
