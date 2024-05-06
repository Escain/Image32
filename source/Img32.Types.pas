unit Img32.Types;

(*******************************************************************************
* Authors   :  Angus Johnson / Adrian Maire                                    *
* Version   :  4.4                                                             *
* Date      :  6 May 2024                                                      *
* Website   :  http://www.angusj.com                                           *
* Copyright :  Angus Johnson 2019-2024                                         *
*                                                                              *
* Purpose   :  Vector drawing for TImage32                                     *
*                                                                              *
* License   :  Use, modification & distribution is subject to                  *
*              Boost Software License Ver 1                                    *
*              http://www.boost.org/LICENSE_1_0.txt                            *
*******************************************************************************)

interface

{$I Img32.inc}

uses
	Types;

type

  TPointD = record
    X, Y: double;
  end;

  TRectD = {$IFDEF RECORD_METHODS} record {$ELSE} object {$ENDIF}
    {$IFNDEF RECORD_METHODS}
    Left, Top, Right, Bottom: Double;
    function TopLeft: TPointD;
    function BottomRight: TPointD;
    {$ENDIF}
    function IsEmpty: Boolean;
    function Width: double;
    function Height: double;
    //Normalize: Returns True if swapping top & bottom or left & right
    function Normalize: Boolean;
    function Contains(const Pt: TPoint): Boolean; overload;
    function Contains(const Pt: TPointD): Boolean; overload;
    function MidPoint: TPointD;
    {$IFDEF RECORD_METHODS}
    case Integer of
      0: (Left, Top, Right, Bottom: Double);
      1: (TopLeft, BottomRight: TPointD);
    {$ENDIF}
  end;

  PPointD = ^TPointD;
  TPathD = array of TPointD;       //nb: watch for ambiguity with Clipper.pas
  TPathsD = array of TPathD;       //nb: watch for ambiguity with Clipper.pas
  TArrayOfPathsD = array of TPathsD;

  TArrayOfInteger = array of Integer;
  TArrayOfWord = array of WORD;
  TArrayOfByte = array of Byte;
  TArrayOfDouble = array of double;
  TArrayOfString = array of string;

  function PointD(const X, Y: Double): TPointD; overload;
  function PointD(const pt: TPoint): TPointD; overload;

  function RectD(left, top, right, bottom: double): TRectD; overload;
  function RectD(const rec: TRect): TRectD; overload;

  procedure NormalizeAngle(var angle: double; tolerance: double = Pi/360);

  //AND BECAUSE OLDER DELPHI COMPILERS (OLDER THAN D2006)
  //DON'T SUPPORT RECORD METHODS
  procedure RectWidthHeight(const rec: TRect; out width, height: Integer);
  {$IFDEF INLINE} inline; {$ENDIF}
  function RectWidth(const rec: TRect): Integer;
  {$IFDEF INLINE} inline; {$ENDIF}
  function RectHeight(const rec: TRect): Integer;
  {$IFDEF INLINE} inline; {$ENDIF}

  function IsEmptyRect(const rec: TRect): Boolean; overload;
  {$IFDEF INLINE} inline; {$ENDIF}
  function IsEmptyRect(const rec: TRectD): Boolean; overload;
  {$IFDEF INLINE} inline; {$ENDIF}

const
  TwoPi = Pi *2;
  angle0   = 0;
  angle1   = Pi/180;
  angle15  = Pi /12;
  angle30  = angle15 *2;
  angle45  = angle15 *3;
  angle60  = angle15 *4;
  angle75  = angle15 *5;
  angle90  = Pi /2;
  angle105 = Pi - angle75;
  angle120 = Pi - angle60;
  angle135 = Pi - angle45;
  angle150 = Pi - angle30;
  angle165 = Pi - angle15;
  angle180 = Pi;
  angle195 = Pi + angle15;
  angle210 = Pi + angle30;
  angle225 = Pi + angle45;
  angle240 = Pi + angle60;
  angle255 = Pi + angle75;
  angle270 = TwoPi - angle90;
  angle285 = TwoPi - angle75;
  angle300 = TwoPi - angle60;
  angle315 = TwoPi - angle45;
  angle330 = TwoPi - angle30;
  angle345 = TwoPi - angle15;
  angle360 = TwoPi;

var
  ClockwiseRotationIsAnglePositive: Boolean = true;

implementation

uses
  Math;

//------------------------------------------------------------------------------
// TRectD methods (and helpers)
//------------------------------------------------------------------------------

function TRectD.IsEmpty: Boolean;
begin
  result := (right <= left) or (bottom <= top);
end;
//------------------------------------------------------------------------------

function TRectD.Width: double;
begin
  result := Max(0, right - left);
end;
//------------------------------------------------------------------------------

function TRectD.Height: double;
begin
  result := Max(0, bottom - top);
end;
//------------------------------------------------------------------------------

function TRectD.MidPoint: TPointD;
begin
  Result.X := (Right + Left)/2;
  Result.Y := (Bottom + Top)/2;
end;
//------------------------------------------------------------------------------

{$IFNDEF RECORD_METHODS}
function TRectD.TopLeft: TPointD;
begin
  Result.X := Left;
  Result.Y := Top;
end;
//------------------------------------------------------------------------------

function TRectD.BottomRight: TPointD;
begin
  Result.X := Right;
  Result.Y := Bottom;
end;
//------------------------------------------------------------------------------
{$ENDIF}

function TRectD.Normalize: Boolean;
var
  d: double;
begin
  Result := false;
  if Left > Right then
  begin
    d := Left;
    Left := Right;
    Right := d;
    Result := True;
  end;
  if Top > Bottom then
  begin
    d := Top;
    Top := Bottom;
    Bottom := d;
    Result := True;
  end;
end;
//------------------------------------------------------------------------------

function TRectD.Contains(const Pt: TPoint): Boolean;
begin
  Result := (pt.X >= Left) and (pt.X < Right) and
    (pt.Y >= Top) and (pt.Y < Bottom);
end;
//------------------------------------------------------------------------------

function TRectD.Contains(const Pt: TPointD): Boolean;
begin
  Result := (pt.X >= Left) and (pt.X < Right) and
    (pt.Y >= Top) and (pt.Y < Bottom);
end;
//------------------------------------------------------------------------------

function RectD(left, top, right, bottom: double): TRectD;
begin
  result.Left := left;
  result.Top := top;
  result.Right := right;
  result.Bottom := bottom;
end;
//------------------------------------------------------------------------------

function RectD(const rec: TRect): TRectD;
begin
  with rec do
  begin
    result.Left := left;
    result.Top := top;
    result.Right := right;
    result.Bottom := bottom;
  end;
end;

//------------------------------------------------------------------------------

function PointD(const X, Y: Double): TPointD;
begin
  Result.X := X;
  Result.Y := Y;
end;
//------------------------------------------------------------------------------

function PointD(const pt: TPoint): TPointD;
begin
  Result.X := pt.X;
  Result.Y := pt.Y;
end;
//------------------------------------------------------------------------------

procedure RectWidthHeight(const rec: TRect; out width, height: Integer);
begin
  width := rec.Right - rec.Left;
  height := rec.Bottom - rec.Top;
end;
//------------------------------------------------------------------------------

function RectWidth(const rec: TRect): Integer;
begin
  Result := rec.Right - rec.Left;
end;
//------------------------------------------------------------------------------

function RectHeight(const rec: TRect): Integer;
begin
  Result := rec.Bottom - rec.Top;
end;
//------------------------------------------------------------------------------

function IsEmptyRect(const rec: TRect): Boolean;
begin
  Result := (rec.Right <= rec.Left) or (rec.Bottom <= rec.Top);
end;
//------------------------------------------------------------------------------

function IsEmptyRect(const rec: TRectD): Boolean;
begin
  Result := (rec.Right <= rec.Left) or (rec.Bottom <= rec.Top);
end;
//------------------------------------------------------------------------------

procedure NormalizeAngle(var angle: double; tolerance: double = Pi/360);
var
  aa: double;
begin
  angle := FMod(angle, angle360);
  if angle < -Angle180 then angle := angle + angle360
  else if angle > angle180 then angle := angle - angle360;

  aa := Abs(angle);
  if aa < tolerance then angle := 0
  else if aa > angle180 - tolerance then angle := angle180
  else if (aa < angle90 - tolerance) or (aa > angle90 + tolerance) then Exit
  else if angle < 0 then angle := -angle90
  else angle := angle90;
end;


end.

