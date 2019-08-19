unit Image32_Vector;

(*******************************************************************************
* Author    :  Angus Johnson                                                   *
* Version   :  1.18                                                            *
* Date      :  18 August 2019                                                  *
* Website   :  http://www.angusj.com                                           *
* Copyright :  Angus Johnson 2010-2019                                         *
* Purpose   :  Vector drawing for TImage32                                     *
* License   :  http://www.boost.org/LICENSE_1_0.txt                            *
*******************************************************************************)

interface

{$I Image32.inc}

uses
  SysUtils, Classes, Windows, Math, {$IFDEF INLINE} Types, {$ENDIF} Image32;

type
  TArrowStyle = (asSimple, asFancy, asDiamond, asCircle);
  TJoinStyle  = (jsAuto, jsSquare, jsMiter, jsRound);
  TEndStyle   = (esClosed, esButt, esSquare, esRound);
  TPathEnd    = (peStart, peEnd, peBothEnds);
  TSplineType = (stQuadratic, stCubic);

  function InflateRect(const rec: TRectD; dx, dy: double): TRectD; overload;

  function Rectangle(const rec: TRect): TArrayOfPointD; overload;
  function Rectangle(const rec: TRectD): TArrayOfPointD; overload;
  function Rectangle(l, t, r, b: double): TArrayOfPointD; overload;

  function RoundRect(const rec: TRect; radius: integer): TArrayOfPointD; overload;
  function RoundRect(const rec: TRectD; radius: double): TArrayOfPointD; overload;

  function Ellipse(const rec: TRect; steps: integer = 0): TArrayOfPointD; overload;
  function Ellipse(const rec: TRectD; steps: integer = 0): TArrayOfPointD; overload;

  function Star(const focalPt: TPointD;
    innerRadius, outerRadius: double; points: integer): TArrayOfPointD;

  function Arc(const rec: TRect; startAngle, endAngle: double): TArrayOfPointD;
  function Pie(const rec: TRect; StartAngle, EndAngle: double): TArrayOfPointD;

  function QBezier(const pt1, pt2, pt3: TPointD): TArrayOfPointD; overload;
  function QBezier(const pts: TArrayOfPointD): TArrayOfPointD; overload;
  function CBezier(const pt1, pt2, pt3, pt4: TPointD): TArrayOfPointD; overload;
  function CBezier(const pts: TArrayOfPointD): TArrayOfPointD; overload;

  //CSpline: Approximates the 'S' command inside the 'd' property of an
  //SVG path. (See https://www.w3.org/TR/SVG/paths.html#DProperty)
  function CSpline(const pts: TArrayOfPointD): TArrayOfPointD;

  //QSpline: Approximates the 'T' command inside the 'd' property of an
  //SVG path. (See https://www.w3.org/TR/SVG/paths.html#DProperty)
  function QSpline(const pts: TArrayOfPointD): TArrayOfPointD;

  //ArrowHead: The ctrlPt's only function is to control the angle of the arrow.
  function ArrowHead(const arrowTip, ctrlPt: TPointD; size: double;
    arrowStyle: TArrowStyle): TArrayOfPointD;
  function ShortenPath(const path: TArrayOfPointD;
    pathEnd: TPathEnd; amount: double): TArrayOfPointD;

  //GetDashPath: Returns a polyline (not polygons)
  function GetDashedPath(const path: TArrayOfPointD;
    closed: Boolean; const pattern: TArrayOfInteger;
    patternOffset: PDouble): TArrayOfArrayOfPointD;

  function GetDashedOutLine(const path: TArrayOfPointD;
    closed: Boolean; const pattern: TArrayOfInteger;
    patternOffset: PDouble; lineWidth: double;
    joinStyle: TJoinStyle; endStyle: TEndStyle): TArrayOfArrayOfPointD;

  //CopyPaths: Because only dynamic string arrays are copy-on-write
  //function CopyPaths(const paths: TArrayOfArrayOfPointD): TArrayOfArrayOfPointD;

  function OffsetPoint(const pt: TPoint; dx, dy: integer): TPoint; overload;
  function OffsetPoint(const pt: TPointD; dx, dy: double): TPointD; overload;

  function OffsetPath(const path: TArrayOfPointD;
    dx, dy: double): TArrayOfPointD; overload;
  function OffsetPath(const paths: TArrayOfArrayOfPointD;
    dx, dy: double): TArrayOfArrayOfPointD; overload;
  function ScalePath(const path: TArrayOfPointD;
    sx, sy: double): TArrayOfPointD; overload;
  function ScalePath(const paths: TArrayOfArrayOfPointD;
    sx, sy: double): TArrayOfArrayOfPointD; overload;
  function ReversePath(const path: TArrayOfPointD): TArrayOfPointD;
  procedure AddToPath(var path: TArrayOfPointD;
    const extra: TArrayOfPointD);
  procedure AppendPath(var paths: TArrayOfArrayOfPointD;
    const extra: TArrayOfPointD);
    {$IFDEF INLINE} inline; {$ENDIF} overload;
  procedure AppendPath(var paths: TArrayOfArrayOfPointD;
    const extra: TArrayOfArrayOfPointD);
    {$IFDEF INLINE} inline; {$ENDIF} overload;

  function RotatePath(const path: TArrayOfPointD;
    const focalPoint: TPointD; angleRads: double): TArrayOfPointD;

  function MakePathI(const pts: array of integer): TArrayOfPointD; overload;
  function MakePathD(const pts: array of double): TArrayOfPointD; overload;

  function GetBounds(const path: TArrayOfPointD): TRect; overload;
  function GetBounds(const paths: TArrayOfArrayOfPointD): TRect; overload;
  function GetBoundsD(const path: TArrayOfPointD): TRectD; overload;
  function GetBoundsD(const paths: TArrayOfArrayOfPointD): TRectD; overload;

  function Rect(const recD: TRectD): TRect; overload;
  function Rect(const l,t,r,b: integer): TRect; overload;
  function RectsEqual(const rec1, rec2: TRect): Boolean;
  procedure OffsetRect(var rec: TRectD; dx, dy: double); overload;

  function Point(const pt: TPointD): TPoint; overload;

  function MidPoint(const rec: TRect): TPoint; overload;
  function MidPoint(const rec: TRectD): TPointD; overload;

  function MidPoint(const pt1, pt2: TPoint): TPoint; overload;
  function MidPoint(const pt1, pt2: TPointD): TPointD; overload;

  function ReflectPoint(const pt, pivot: TPointD): TPointD;

  function IntersectRect(const rec1, rec2: TRectD): TRectD;
  function UnionRect(const rec1, rec2: TRectD): TRectD;

  //these 2 functions are only needed to support older versions of Delphi
  function MakeArrayOfInteger(const ints: array of integer): TArrayOfInteger;
  function MakeArrayOfDouble(const doubles: array of double): TArrayOfDouble;

  function CrossProduct(const pt1, pt2, pt3: TPointD): double;
  function TurnsLeft(const pt1, pt2, pt3: TPointD): boolean;
  {$IFDEF INLINING} inline; {$ENDIF}
  function TurnsRight(const pt1, pt2, pt3: TPointD): boolean;
  {$IFDEF INLINING} inline; {$ENDIF}
  function IsPathConvex(const path: TArrayOfPointD): Boolean;

  //GetUnitVector: Used internally
  function GetUnitVector(const pt1, pt2: TPointD): TPointD;
  {$IFDEF INLINE} inline; {$ENDIF}
  //GetUnitNormal: Used internally
  function GetUnitNormal(const pt1, pt2: TPointD): TPointD;
  {$IFDEF INLINE} inline; {$ENDIF}
  //GetVectors: Used internally
  function GetVectors(const path: TArrayOfPointD): TArrayOfPointD;
  //GetNormals: Used internally
  function GetNormals(const path: TArrayOfPointD): TArrayOfPointD;
  //DistanceSqrd: Used internally
  function DistanceSqrd(const pt1, pt2: TPoint): double; overload;
  {$IFDEF INLINE} inline; {$ENDIF}
  //DistanceSqrd: Used internally
  function DistanceSqrd(const pt1, pt2: TPointD): double; overload;
  {$IFDEF INLINE} inline; {$ENDIF}
  function Distance(const pt1, pt2: TPoint): double; overload;
  {$IFDEF INLINE} inline; {$ENDIF}
  function Distance(const pt1, pt2: TPointD): double; overload;
  {$IFDEF INLINE} inline; {$ENDIF}

  function IsPointInEllipse(const ellipseRec: TRect; const pt: TPoint): Boolean;

  //GetIntersectsEllipseAndLine: Gets the intersection of an ellipse and
  //a line. The function result = true when the line either touches
  //tangentially or passes through the ellipse. If the line touches
  //tangentially, the coordintates returned in pt1 and pt2 will match.
  function GetLineEllipseIntersects(const ellipseRect: TRect;
    var linePt1, linePt2: TPointD): Boolean;

  function Outline(const line: TArrayOfPointD; lineWidth: double;
    joinStyle: TJoinStyle; endStyle: TEndStyle;
    miterLimit: double = 0): TArrayOfArrayOfPointD; overload;
  function Outline(const lines: TArrayOfArrayOfPointD; lineWidth: double;
    joinStyle: TJoinStyle; endStyle: TEndStyle;
    miterLimit: double = 0): TArrayOfArrayOfPointD; overload;

   //Grow: Offsets a closed path by 'delta' amount toward the left of the path.
   //Hence clockwise paths expand and counter-clockwise paths contract.<br>
   //No consideration is given to overlapping joins as these only very rarely
   //cause artifacts when paths are rendered.
  function Grow(const path, normals: TArrayOfPointD; delta: double;
    joinStyle: TJoinStyle; miterLimit: double): TArrayOfPointD;

const
  NullPoint: TPoint = (X: 0; Y: 0);
  NullPointD: TPointD = (X: 0; Y: 0);
  NullRect: TRect = (left: 0; top: 0; right: 0; Bottom: 0);
  NullRectD: TRectD = (left: 0; top: 0; right: 0; Bottom: 0);

var
  //AutoWidthThreshold: When JoinStyle = jsAuto, this is the threshold at
  //which lines joins will be rounded instead of squared. With wider strokes,
  //rounded joins generally look better, but as rounding is more complex it
  //also requries more processing and hence is slower to execute.
  AutoWidthThreshold: double = 5.0;

  //Line stroke widths of less than about 1.3 will produce noticeable
  //Moire effect when the lines are close to horizontal or close to vertical
  MinStrokeWidth: double = 0.5; //1.33;

  //DefaultMiterLimit: Avoids excessive spikes when line offsetting
  DefaultMiterLimit: double = 2.0;

implementation

resourcestring
  rsInvalidQBezier = 'Invalid QBezier - requires 3 points';
  rsInvalidCBezier = 'Invalid CBezier - requires 4 points';

type
  TArray256Bytes = array[0..255] of byte;

const
  CBezierTolerance  = 0.25;
  QBezierTolerance  = 0.25;
  BuffSize          = 128;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function RectsEqual(const rec1, rec2: TRect): Boolean;
begin
  result := (rec1.Left = rec2.Left) and (rec1.Top = rec2.Top) and
    (rec1.Right = rec2.Right) and (rec1.Bottom = rec2.Bottom);
end;
//------------------------------------------------------------------------------

function Point(const pt: TPointD): TPoint;
begin
  result.X := Round(pt.x);
  result.Y := Round(pt.y);
end;
//------------------------------------------------------------------------------

function Rect(const l,t,r,b: integer): TRect;
begin
  Result.Left := l;
  Result.Top := t;
  Result.Right := r;
  Result.Bottom := b;
end;
//------------------------------------------------------------------------------

function Rect(const recD: TRectD): TRect;
begin
  Result.Left := Floor(recD.Left);
  Result.Top := Floor(recD.Top);
  Result.Right := Ceil(recD.Right);
  Result.Bottom := Ceil(recD.Bottom);
end;
//------------------------------------------------------------------------------

procedure OffsetRect(var rec: TRectD; dx, dy: double);
begin
  rec.Left := rec.Left + dx;
  rec.Top := rec.Top + dy;
  rec.Right := rec.Right + dx;
  rec.Bottom := rec.Bottom + dy;
end;
//------------------------------------------------------------------------------

function MidPoint(const rec: TRect): TPoint;
begin
  Result.X := (rec.Left + rec.Right) div 2;
  Result.Y := (rec.Top + rec.Bottom) div 2;
end;
//------------------------------------------------------------------------------

function MidPoint(const rec: TRectD): TPointD;
begin
  Result.X := (rec.Left + rec.Right) * 0.5;
  Result.Y := (rec.Top + rec.Bottom) * 0.5;
end;
//------------------------------------------------------------------------------

function MidPoint(const pt1, pt2: TPoint): TPoint;
begin
  Result.X := (pt1.X + pt2.X) div 2;
  Result.Y := (pt1.Y + pt2.Y) div 2;
end;
//------------------------------------------------------------------------------

function MidPoint(const pt1, pt2: TPointD): TPointD;
begin
  Result.X := (pt1.X + pt2.X) * 0.5;
  Result.Y := (pt1.Y + pt2.Y) * 0.5;
end;
//------------------------------------------------------------------------------

function IntersectRect(const rec1, rec2: TRectD): TRectD;
begin
  result.Left := Max(rec1.Left, rec2.Left);
  result.Top := Max(rec1.Top, rec2.Top);
  result.Right := Min(rec1.Right, rec2.Right);
  result.Bottom := Min(rec1.Bottom, rec2.Bottom);
end;
//------------------------------------------------------------------------------

function UnionRect(const rec1, rec2: TRectD): TRectD;
begin
  result.Left := Min(rec1.Left, rec2.Left);
  result.Top := Min(rec1.Top, rec2.Top);
  result.Right := Max(rec1.Right, rec2.Right);
  result.Bottom := Max(rec1.Bottom, rec2.Bottom);
end;
//------------------------------------------------------------------------------

function MakeArrayOfInteger(const ints: array of integer): TArrayOfInteger;
var
  i, len: integer;
begin
  len := Length(ints);
  SetLength(Result, len);
  for i := 0 to len -1 do Result[i] := ints[i];
end;
//------------------------------------------------------------------------------

function MakeArrayOfDouble(const doubles: array of double): TArrayOfDouble;
var
  i, len: integer;
begin
  len := Length(doubles);
  SetLength(Result, len);
  for i := 0 to len -1 do Result[i] := doubles[i];
end;
//------------------------------------------------------------------------------

function CrossProduct(const pt1, pt2, pt3: TPointD): double;
var
  x1,x2,y1,y2: double;
begin
  x1 := pt2.X - pt1.X;
  y1 := pt2.Y - pt1.Y;
  x2 := pt3.X - pt2.X;
  y2 := pt3.Y - pt2.Y;
  result := (x1 * y2 - y1 * x2);
end;
//---------------------------------------------------------------------------

function TurnsLeft(const pt1, pt2, pt3: TPointD): boolean;
begin
  result := CrossProduct(pt1, pt2, pt3) < 0;
end;
//---------------------------------------------------------------------------

function TurnsRight(const pt1, pt2, pt3: TPointD): boolean;
begin
  result := CrossProduct(pt1, pt2, pt3) > 0;
end;
//---------------------------------------------------------------------------

function IsPathConvex(const path: TArrayOfPointD): Boolean;
var
  i, pathLen: integer;
  dir: boolean;
begin
  result := false;
  pathLen := length(path);
  if pathLen < 3 then Exit;
  //get the winding direction of the first angle
  dir := TurnsRight(path[0], path[1], path[2]);
  //check that each other angle has the same winding direction
  for i := 1 to pathLen -1 do
    if TurnsRight(path[i], path[(i+1) mod pathLen],
      path[(i+2) mod pathLen]) <> dir then Exit;
  result := true;
end;
//------------------------------------------------------------------------------

function GetUnitVector(const pt1, pt2: TPointD): TPointD;
{$IFDEF INLINE} inline; {$ENDIF}
var
  dx, dy, inverseHypot: Double;
begin
  if (pt1.x = pt2.x) and (pt1.y = pt2.y) then
  begin
    Result.X := 0;
    Result.Y := 0;
    Exit;
  end;
  dx := (pt2.X - pt1.X);
  dy := (pt2.Y - pt1.Y);
  inverseHypot := 1 / Hypot(dx, dy);
  dx := dx * inverseHypot;
  dy := dy * inverseHypot;
  Result.X := dx;
  Result.Y := dy;
end;
//------------------------------------------------------------------------------

function GetUnitNormal(const pt1, pt2: TPointD): TPointD;
{$IFDEF INLINE} inline; {$ENDIF}
var
  dx, dy, inverseHypot: Double;
begin
  if (pt1.x = pt2.x) and (pt1.y = pt2.y) then
  begin
    Result.X := 0;
    Result.Y := 0;
    Exit;
  end;
  dx := (pt2.X - pt1.X);
  dy := (pt2.Y - pt1.Y);
  inverseHypot := 1 / Hypot(dx, dy);
  dx := dx * inverseHypot;
  dy := dy * inverseHypot;
  Result.X := dy;
  Result.Y := -dx
end;
//------------------------------------------------------------------------------

function CopyPaths(const paths: TArrayOfArrayOfPointD): TArrayOfArrayOfPointD;
var
  i, len1: integer;
begin
  len1 := length(paths);
  setLength(result, len1);
  for i := 0 to len1 -1 do
    result[i] := Copy(paths[i], 0, length(paths[i]));
end;
//------------------------------------------------------------------------------

function OffsetPoint(const pt: TPoint; dx, dy: integer): TPoint;
begin
  result.x := pt.x + dx;
  result.y := pt.y + dy;
end;
//------------------------------------------------------------------------------

function OffsetPoint(const pt: TPointD; dx, dy: double): TPointD;
begin
  result.x := pt.x + dx;
  result.y := pt.y + dy;
end;
//------------------------------------------------------------------------------

function OffsetPath(const path: TArrayOfPointD; dx, dy: double): TArrayOfPointD;
var
  i, len: integer;
begin
  len := length(path);
  setLength(result, len);
  for i := 0 to len -1 do
  begin
    result[i].x := path[i].x + dx;
    result[i].y := path[i].y + dy;
  end;
end;
//------------------------------------------------------------------------------

function OffsetPath(const paths: TArrayOfArrayOfPointD;
  dx, dy: double): TArrayOfArrayOfPointD;
var
  i,len: integer;
begin
  len := length(paths);
  setLength(result, len);
  for i := 0 to len -1 do
    result[i] := OffsetPath(paths[i], dx, dy);
end;
//------------------------------------------------------------------------------

function ScalePath(const path: TArrayOfPointD; sx, sy: double): TArrayOfPointD;
var
  i, len: integer;
begin
  if sx = 0 then sx := 1;
  if sy = 0 then sy := 1;
  len := length(path);
  setLength(result, len);
  for i := 0 to len -1 do
  begin
    result[i].x := path[i].x * sx;
    result[i].y := path[i].y * sy;
  end;
end;
//------------------------------------------------------------------------------

function ScalePath(const paths: TArrayOfArrayOfPointD;
  sx, sy: double): TArrayOfArrayOfPointD;
var
  i,len: integer;
begin
  len := length(paths);
  setLength(result, len);
  for i := 0 to len -1 do
    result[i] := ScalePath(paths[i], sx, sy);
end;
//------------------------------------------------------------------------------

function ReversePath(const path: TArrayOfPointD): TArrayOfPointD;
var
  i, highI: integer;
begin
  highI := High(path);
  SetLength(result, highI +1);
  for i := 0 to highI do
    result[i] := path[highI -i];
end;
//------------------------------------------------------------------------------

function ReversePathSpecial(const path: TArrayOfPointD): TArrayOfPointD;
var
  i, highI: integer;
begin
  //trims first and last point from reversed path
  result := nil;
  highI := High(path);
  if highI < 2 then Exit;
  SetLength(result, highI -1);
  for i := 0 to highI -2 do
    result[i] := path[highI-1 -i];
end;
//------------------------------------------------------------------------------

function GetVectors(const path: TArrayOfPointD): TArrayOfPointD;
var
  i,j, len: cardinal;
  pt: TPointD;
begin
  len := length(path);
  setLength(result, len);
  if len = 0 then Exit;
  pt := path[0];
  //skip duplicates
  i := len -1;
  while (i > 0) and
    (path[i].X = pt.X) and (path[i].Y = pt.Y) do dec(i);
  if (i = 0) then
  begin
    //all points are equal!
    for i := 0 to len -1 do result[i] := PointD(0,0);
    Exit;
  end;
  result[i] := GetUnitVector(path[i], pt);
  //fix up any duplicates at the end of the path
  for j := i +1 to len -1 do
    result[j] := result[j-1];
  //with at least one valid vector, we can now
  //safely get the remaining vectors
  pt := path[i];
  for i := i -1 downto 0 do
  begin
    if (path[i].X <> pt.X) or (path[i].Y <> pt.Y) then
    begin
      result[i] := GetUnitVector(path[i], pt);
      pt := path[i];
    end else
      result[i] := result[i+1]
  end;
end;
//------------------------------------------------------------------------------

function GetNormals(const path: TArrayOfPointD): TArrayOfPointD;
var
  i,j, len: cardinal;
  pt: TPointD;
begin
  len := length(path);
  setLength(result, len);
  if len = 0 then Exit;
  pt := path[0];
  //skip duplicates
  i := len -1;
  while (i > 0) and
    (path[i].X = pt.X) and (path[i].Y = pt.Y) do dec(i);
  if (i = 0) then
  begin
    //all points are equal!
    for i := 0 to len -1 do result[i] := PointD(0,0);
    Exit;
  end;
  result[i] := GetUnitNormal(path[i], pt);
  //fix up any duplicates at the end of the path
  for j := i +1 to len -1 do
    result[j] := result[j-1];
  //with at least one valid vector, we can now
  //safely get the remaining vectors
  pt := path[i];
  for i := i -1 downto 0 do
  begin
    if (path[i].X <> pt.X) or (path[i].Y <> pt.Y) then
    begin
      result[i] := GetUnitNormal(path[i], pt);
      pt := path[i];
    end else
      result[i] := result[i+1]
  end;
end;
//------------------------------------------------------------------------------

function DistanceSqrd(const pt1, pt2: TPoint): double;
begin
  result := Sqr(pt1.X - pt2.X) + Sqr(pt1.Y - pt2.Y);
end;
//------------------------------------------------------------------------------

function DistanceSqrd(const pt1, pt2: TPointD): double;
begin
  result := Sqr(pt1.X - pt2.X) + Sqr(pt1.Y - pt2.Y);
end;
//------------------------------------------------------------------------------

function Distance(const pt1, pt2: TPoint): double;
begin
  Result := Sqrt(DistanceSqrd(pt1, pt2));
end;
//------------------------------------------------------------------------------

function Distance(const pt1, pt2: TPointD): double;
begin
  Result := Sqrt(DistanceSqrd(pt1, pt2));
end;
//------------------------------------------------------------------------------

function IsPointInEllipse(const ellipseRec: TRect; const pt: TPoint): Boolean;
var
  rec: TRectD;
  x,y, y2, a,b, dx,dy: double;
begin
  a := RectWidth(ellipseRec) *0.5;
  b := RectHeight(ellipseRec) *0.5;
  dx := ellipseRec.Left + a;
  dy := ellipseRec.Top + b;
  rec := RectD(ellipseRec);
  OffsetRect(rec, -dx, -dy);
  x := pt.X -dx; y := pt.Y -dy;
  //first make sure pt is inside rect
  Result := (abs(x) <= a) and (abs(y) <= b);
  if not result then Exit;
  //given (x*x)/(a*a) + (y*y)/(b*b) = 1
  //then y*y = b*b(1 - (x*x)/(a*a))
  //nb: contents of Sqrt below will always be positive
  //since the substituted x must be within ellipseRec bounds
  y2 := Sqrt((b*b*(1 - (x*x)/(a*a))));
  Result := (y >= -y2) and (y <= y2);
end;
//------------------------------------------------------------------------------

function GetLineEllipseIntersects(const ellipseRect: TRect;
  var linePt1, linePt2: TPointD): Boolean;
var
  dx, dy, m,a,b,c,q: double;
  qa,qb,qc,qs: double;
  rec: TRectD;
  pt1, pt2: TPointD;
begin
  a := RectWidth(ellipseRect) *0.5;
  b := RectHeight(ellipseRect) *0.5;
  //offset ellipseRect so it's centered over the coordinate origin
  dx := ellipseRect.Left + a; dy := ellipseRect.Top + b;
  rec := RectD(ellipseRect);
  offsetRect(rec, -dx, -dy);
  pt1 := OffsetPoint(linePt1, -dx, -dy);
  pt2 := OffsetPoint(linePt2, -dx, -dy);
  //equation of ellipse = (x*x)/(a*a) + (y*y)/(b*b) = 1
  //equation of line = y = mx + c;
  if (pt1.X = pt2.X) then //vertical line (ie infinite slope)
  begin
    //given x = K, then y*y = b*b(1 - (x*x)/(a*a))
    q := (b*b)*(1 - Sqr(pt1.X)/(a*a));
    result := q >= 0;
    if not result then Exit;
    q := Sqrt(q);
    pt1.Y := q;
    pt2.Y := -q;
  end else
  begin
    //using simultaneous equations and substitution
    //given y = mx + c
    m := (pt1.Y - pt2.Y)/(pt1.X - pt2.X);
    c := pt1.Y - m * pt1.X;
    //given (x*x)/(a*a) + (y*y)/(b*b) = 1
    //(x*x)/(a*a)*(b*b) + (y*y) = (b*b)
    //(b*b)/(a*a) *(x*x) + Sqr(m*x +c) = (b*b)
    //(b*b)/(a*a) *(x*x) + (m*m)*(x*x) + 2*m*x*c +c*c = b*b
    //((b*b)/(a*a) +(m*m)) *(x*x) + 2*m*c*(x) + (c*c) - (b*b) = 0
    //solving quadratic equation
    qa := ((b*b)/(a*a) +(m*m));
    qb := 2*m*c;
    qc := (c*c) - (b*b);
    qs := (qb*qb) - 4*qa*qc;
    Result := qs >= 0;
    if not result then Exit;
    qs := Sqrt(qs);
    pt1.X := (-qb +qs)/(2 * qa);
    pt1.Y := m * pt1.X + c;
    pt2.X := (-qb -qs)/(2 * qa);
    pt2.Y := m * pt2.X + c;
  end;
  //finally reverse initial offset
  linePt1 := OffsetPoint(pt1, dx, dy);
  linePt2 := OffsetPoint(pt2, dx, dy);
end;
//------------------------------------------------------------------------------

function Grow(const path, normals: TArrayOfPointD; delta: double;
  joinStyle: TJoinStyle; miterLimit: double): TArrayOfPointD;
var
  i,prevI, highI: cardinal;
  buffLen, resultLen: cardinal;
  steps360, stepsPerRad: double;
  stepSin, stepCos, cosA: extended;
  P: TPointD;
  norms: TArrayOfPointD;
  normalA, normalB: TPointD;

  procedure AddPoint(const pt: TPointD);
  begin
    if resultLen >= buffLen then
    begin
      inc(buffLen, 128);
      setLength(result, buffLen);
    end;
    result[resultLen] := pt;
    inc(resultLen);
  end;

  function GetNormal(const pt: TPointD; const norm: TPointD): TPointD;
  begin
    result := PointD(pt.x + norm.x * delta, pt.y + norm.y * delta);
  end;

  procedure AddMiter(const N1, N2: TPointD; cosAplus1: double);
  var
    q: double;
  begin
    q := delta / cosAplus1;
    AddPoint(PointD(P.X + (N2.X + N1.X) * q,
      P.Y + (N1.Y + N2.Y) * q));
  end;

  procedure AddBevel(const N1, N2: TPointD);
  begin
    AddPoint(GetNormal(P, N1));
    AddPoint(GetNormal(P, N2));
  end;

  procedure AddRound(const N1, N2: TPointD; cosA: double);
  var
    i, steps: Integer;
    a, sinA: Double;
    P2: TPointD;
  begin
    sinA := normalA.x * normalB.y - normalA.y * normalB.x;
    if (delta * sinA < 0) then //concave
      AddBevel(N1, N2)
    else
    begin
      a := ArcTan2(sinA, cosA);
      steps := Round(stepsPerRad * Abs(a));
      P2 := PointD(N1.x * delta, N1.y * delta);
      AddPoint(PointD(P.x + P2.x, P.y + P2.y));
      for i := 1 to steps do
      begin
        P2 := PointD(P2.x * stepCos - stepSin * P2.y,
          P2.x * stepSin + P2.y * stepCos);
        AddPoint(PointD(P.x + P2.x, P.y + P2.y));
      end;
    end;
  end;

begin
  highI := high(path);
  if (highI < 1) then exit;
  if delta < MinStrokeWidth/2 then delta := MinStrokeWidth/2;

  if delta < 1 then        //ie linewidth < 2
    joinStyle := jsSquare
  else if joinStyle = jsAuto then
  begin
    if delta < AutoWidthThreshold / 2 then
      joinStyle := jsSquare else
      joinStyle := jsRound;
  end;

  if joinStyle = jsRound then
  begin
    steps360 := PI / ArcCos(1 - 0.2 / abs(delta));
    stepsPerRad := steps360 / (Pi *2);
    SinCos(Pi*2/steps360, stepSin, stepCos);
  end;

  result := nil; resultLen := 0; buffLen := 0;
  if miterLimit < 1 then miterLimit := DefaultMiterLimit
  else miterLimit := 2/(sqr(miterLimit));

  norms := normals;
  if not assigned(norms) then
    norms := GetNormals(path);

  PrevI := HighI;
  for i := 0 to HighI do
  begin
    P := path[i];
    normalA := norms[PrevI];
    normalB := norms[i];
    cosA := normalB.x * normalA.x + normalB.y * normalA.y;

    case
      joinStyle of
        jsRound: AddRound(normalA, normalB, cosA);
      jsSquare:
        if cosA > 0 then AddMiter(normalA, normalB, cosA +1)
        else AddBevel(normalA, normalB);
      jsMiter:
        if (1 + cosA < miterLimit) then AddBevel(normalA, normalB)
        else AddMiter(normalA, normalB, cosA +1);
    end;
    PrevI := i;
  end;
  setLength(result, resultLen);
end;
//------------------------------------------------------------------------------

procedure AddToPath(var path: TArrayOfPointD; const extra: TArrayOfPointD);
var
  i, len1, len2: integer;
begin
  len1 := length(path);
  len2 := length(extra);
  if len2 > 0 then
  begin
    setLength(path, len1 + len2);
    for i := 0 to len2 -1 do
      path[len1+i] := extra[i];
  end;
end;
//------------------------------------------------------------------------------

procedure AppendPath(var paths: TArrayOfArrayOfPointD;
  const extra: TArrayOfPointD);
var
  len1, len2: integer;
begin
  len1 := length(paths);
  len2 := length(extra);
  if len2 = 0 then Exit;
  setLength(paths, len1 + 1);
  if len1 = 0 then
    paths[0] := Copy(extra, 0, len2) else
    paths[len1] := Copy(extra, 0, len2);
end;
//------------------------------------------------------------------------------

procedure AppendPath(var paths: TArrayOfArrayOfPointD;
  const extra: TArrayOfArrayOfPointD);
var
  i, len1, len2: integer;
begin
  len1 := length(paths);
  len2 := length(extra);
  if len2 > 0 then
  begin
    setLength(paths, len1 + len2);
    for i := 0 to len2 -1 do
      paths[len1+i] := Copy(extra[i], 0, length(extra[i]));
  end;
end;
//------------------------------------------------------------------------------

procedure RotatePt(var pt: TPointD; const center: TPointD; sinA, cosA: double);
var
  tmpX, tmpY: double;
begin
  tmpX := pt.X-center.X;
  tmpY := pt.Y-center.Y;
  pt.X := tmpX * cosA - tmpY * sinA + center.X;
  pt.Y := tmpX * sinA + tmpY * cosA + center.Y;
end;
//------------------------------------------------------------------------------

function RotatePath(const path: TArrayOfPointD;
  const focalPoint: TPointD; angleRads: double): TArrayOfPointD;
var
  i: integer;
  x,y: double;
  sinA, cosA: extended;
begin
  SetLength(Result, length(path));
  Math.SinCos(angleRads, sinA, cosA);
  for i := 0 to high(path) do
  begin
    x := path[i].X - focalPoint.X;
    y := path[i].Y - focalPoint.Y;
    Result[i].X := x * cosA - y * sinA + focalPoint.X;
    Result[i].Y := x * sinA + y * cosA + focalPoint.Y;
  end;
end;
//------------------------------------------------------------------------------

function GrowOpenLine(const line: TArrayOfPointD; width: double;
  joinStyle: TJoinStyle; endStyle: TEndStyle;
  miterLimit: double): TArrayOfArrayOfPointD;
var
  len, x,y, wDiv2: integer;
  wd2: double;
  line1, line2: TArrayOfPointD;
  vec1, vec2: TPointD;
begin
  Result := nil;
  len := length(line);
  if len = 0 then Exit;

  if width < MinStrokeWidth then
    width := MinStrokeWidth;

  if len = 1 then
  begin
    wDiv2 := Round(width/2);
    x := Round(line[0].X);
    y := Round(line[0].Y);
    SetLength(result, 1);
    result[0] := Ellipse(RectD(x -wDiv2, y -wDiv2, x +wDiv2, y +wDiv2));
    Exit;
  end;

  if joinStyle = jsAuto then
  begin
    if (endStyle = esRound) and (width >= AutoWidthThreshold) then
      joinStyle := jsRound else
      joinStyle := jsSquare;
  end;

  if joinStyle = jsRound then
  begin
    line2 := ReversePathSpecial(line);
    AddToPath(line2, line);
  end else
  begin
    line1 := Copy(line, 0, len);
    if endStyle = esSquare then
    begin
      //extend both ends of the line by 1/2 lineWidth
      wd2 := width/2;
      vec1 := GetUnitVector(line1[1], line1[0]);
      vec2 := GetUnitVector(line1[len-2], line1[len-1]);
      with line1[0] do
        line1[0] := PointD(X + vec1.X * wd2, Y + vec1.y * wd2);
      with line1[len-1] do
        line1[len-1] := PointD(X + vec2.X * wd2, Y + vec2.y * wd2);
    end;
    line2 := ReversePathSpecial(line1);
    AddToPath(line2, line1);
  end;
  SetLength(result, 1);
  Result[0] := Grow(line2, nil, width/2, joinStyle, miterLimit);
end;
//------------------------------------------------------------------------------

function ReverseNormals(const norms: TArrayOfPointD): TArrayOfPointD;
var
  i, highI: integer;
begin
  highI := high(norms);
  setLength(result, highI +1);
  for i := 1 to highI  do
  begin
    result[i -1].X := -norms[highI -i].X;
    result[i -1].Y := -norms[highI -i].Y;
  end;
  result[highI].X := -norms[highI].X;
  result[highI].Y := -norms[highI].Y;
end;
//------------------------------------------------------------------------------

function GrowClosedLine(const line: TArrayOfPointD; width: double;
  joinStyle: TJoinStyle; miterLimit: double): TArrayOfArrayOfPointD;
var
  len: integer;
  line2, norms: TArrayOfPointD;
begin
  len := length(line);
  if len < 3 then
  begin
    result := GrowOpenLine(line, width, joinStyle, esClosed, miterLimit);
    Exit;
  end;

  if width < MinStrokeWidth then width := MinStrokeWidth;
  if joinStyle = jsAuto then
  begin
    if width < AutoWidthThreshold then
      joinStyle := jsSquare else
      joinStyle := jsRound;
  end;
  SetLength(Result, 2);
  norms := GetNormals(line);
  Result[0] := Grow(line, norms, width/2, joinStyle, miterLimit);
  line2 := ReversePath(line);
  norms := ReverseNormals(norms);
  Result[1] := Grow(line2, norms, width/2, joinStyle, miterLimit);
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function Outline(const line: TArrayOfPointD; lineWidth: double;
  joinStyle: TJoinStyle; endStyle: TEndStyle;
  miterLimit: double): TArrayOfArrayOfPointD;
begin
  if not assigned(line) then exit;
  if endStyle = esClosed then
    result := GrowClosedLine(line, lineWidth, joinStyle, miterLimit)
  else
    result := GrowOpenLine(line, lineWidth, joinStyle, endStyle, miterLimit);
end;
//------------------------------------------------------------------------------

function Outline(const lines: TArrayOfArrayOfPointD; lineWidth: double;
  joinStyle: TJoinStyle; endStyle: TEndStyle;
  miterLimit: double): TArrayOfArrayOfPointD;
var
  i: integer;

  procedure AddPaths(const paths: TArrayOfArrayOfPointD);
  var
    i, len, len2: integer;
  begin
    len := length(result);
    len2 := length(paths);
    setLength(result, len + len2);
    for i := 0 to len2 -1 do
      result[len+i] := paths[i];
  end;

begin
  result := nil;
  if not assigned(lines) then exit;
  if joinStyle = jsAuto then
  begin
    if endStyle in [esClosed, esRound] then
      joinStyle := jsRound else
      joinStyle := jsSquare;
  end;
  if endStyle = esClosed then
    for i := 0 to high(lines) do
      AddPaths(GrowClosedLine(lines[i],
        lineWidth, joinStyle, miterLimit))
  else
    for i := 0 to high(lines) do
      AddPaths(GrowOpenLine(lines[i],
        lineWidth, joinStyle, endStyle, miterLimit));
end;
//------------------------------------------------------------------------------

function Rectangle(const rec: TRect): TArrayOfPointD;
begin
  setLength(Result, 4);
  with rec do
  begin
    result[0] := PointD(left, top);
    result[1] := PointD(right, top);
    result[2] := PointD(right, bottom);
    result[3] := PointD(left, bottom);
  end;
end;
//------------------------------------------------------------------------------

function Rectangle(const rec: TRectD): TArrayOfPointD;
begin
  setLength(Result, 4);
  with rec do
  begin
    result[0] := PointD(left, top);
    result[1] := PointD(right, top);
    result[2] := PointD(right, bottom);
    result[3] := PointD(left, bottom);
  end;
end;
//------------------------------------------------------------------------------

function Rectangle(l, t, r, b: double): TArrayOfPointD;
begin
  setLength(Result, 4);
  result[0] := PointD(l, t);
  result[1] := PointD(r, t);
  result[2] := PointD(r, b);
  result[3] := PointD(l, b);
end;
//------------------------------------------------------------------------------

function InflateRect(const rec: TRectD; dx, dy: double): TRectD;
begin
  result.Left := rec.Left - dx;
  result.Top := rec.Top - dy;
  result.Right := rec.Right + dx;
  result.Bottom := rec.Bottom + dy;
end;
//------------------------------------------------------------------------------

function RoundRect(const rec: TRect; radius: integer): TArrayOfPointD;
var
  rec2: TRect;
begin
  rec2 := rec;
  Windows.InflateRect(rec2, -radius, -radius);
  if IsEmptyRect(rec2) then
    result := nil else
    result := Grow(Rectangle(rec2), nil, radius, jsRound, 2);
end;
//------------------------------------------------------------------------------

function RoundRect(const rec: TRectD; radius: double): TArrayOfPointD;
var
  rec2: TRectD;
begin
  rec2 := InflateRect(rec, -radius, -radius);
  if rec2.IsEmpty then
    result := Rectangle(rec) else
    result := Grow(Rectangle(rec2), nil, radius, jsRound, 2);
end;
//------------------------------------------------------------------------------

function Ellipse(const rec: TRect; steps: integer = 0): TArrayOfPointD;
begin
  Result := Ellipse(RectD(rec), steps);
end;
//------------------------------------------------------------------------------

function Ellipse(const rec: TRectD; steps: integer): TArrayOfPointD;
var
  i: Integer;
  f: double;
  sinA, cosA: extended;
  centre, radius, delta: TPointD;
begin
  result := nil;
  if rec.IsEmpty then Exit;
  with rec do
  begin
    centre := PointD((left+right)/2, (top+bottom)/2);
    radius := PointD(width/2, Height/2);
  end;
  f := (radius.x + radius.y)/2;
  if steps < 3 then
    steps := Max(3, Trunc(Pi / (ArcCos(f / (f + 0.125)))));
  SinCos(2 * Pi / Steps, sinA, cosA);
  delta.x := cosA; delta.y := sinA;

  SetLength(Result, Steps);
  Result[0] := PointD(centre.X + radius.X, centre.Y);
  for i := 1 to steps -1 do
  begin
    Result[i] := PointD(centre.X + radius.X * delta.x,
      centre.Y + radius.y * delta.y);
    delta :=  PointD(delta.X * cosA - delta.Y * sinA,
      delta.Y * cosA + delta.X * sinA);
  end;
end;
//------------------------------------------------------------------------------

function Star(const focalPt: TPointD;
  innerRadius, outerRadius: double; points: integer): TArrayOfPointD;
var
  i: Integer;
  sinA, cosA: extended;
  delta: TPointD;
begin
  result := nil;
  if (innerRadius <= 0) or (outerRadius <= 0) then Exit;
  if points <= 5 then points := 10
  else points := points * 2;
  SinCos(2 * Pi / points, sinA, cosA);
  delta.x := cosA; delta.y := sinA;
  SetLength(Result, points);
  Result[0] := PointD(focalPt.X + innerRadius, focalPt.Y);
  for i := 1 to points -1 do
  begin
    if Odd(i) then
      Result[i] := PointD(focalPt.X + outerRadius * delta.x,
        focalPt.Y + outerRadius * delta.y)
    else
      Result[i] := PointD(focalPt.X + innerRadius * delta.x,
        focalPt.Y + innerRadius * delta.y);
    delta :=  PointD(delta.X * cosA - delta.Y * sinA,
      delta.Y * cosA + delta.X * sinA);
  end;
end;
//------------------------------------------------------------------------------

function Arc(const rec: TRect; startAngle, endAngle: double): TArrayOfPointD;
var
  i, steps: Integer;
  angle, radiusMax: double;
  sinA, cosA: extended;
  centre, radius: TPointD;
  deltaX, deltaX2, deltaY: extended;
begin
  if (endAngle = startAngle) or IsEmptyRect(rec) then Exit;
  centre := PointD((rec.left+rec.right)/2, (rec.top+rec.bottom)/2);
  radius := PointD(RectWidth(rec)/2, RectHeight(rec)/2);
  radiusMax := Max(radius.x, radius.y);
  angle := endAngle - startAngle;
  if angle < 0 then angle := Pi * 2 + angle;
  //steps = (No. steps for a whole ellipse) * angle/(2*Pi)
  steps := Max(2, Trunc(Pi/ArcCos(1 - 0.2/radiusMax) * angle /(2*Pi) ));

  SetLength(Result, Steps +1);
  //angle of the first step ...
  SinCos(-startAngle, deltaY, deltaX);
  Result[0].X := centre.X + radius.X * deltaX;
  Result[0].Y := centre.Y + radius.y * deltaY;
  //angle of each subsequent step ...
  SinCos(-angle / Steps, sinA, cosA);
  for i := 1 to steps do
  begin
    deltaX2 := deltaX * cosA - deltaY * sinA;
    deltaY := deltaY * cosA + deltaX * sinA;
    deltaX := deltaX2;
    Result[i] := PointD(centre.X + radius.X * deltaX,
      centre.Y + radius.y * deltaY);
  end;
end;
//------------------------------------------------------------------------------

function Pie(const rec: TRect; StartAngle, EndAngle: double): TArrayOfPointD;
var
  len: integer;
begin
  result := Arc(rec, StartAngle, EndAngle);
  len := length(result);
  setLength(result, len +1);
  result[len] := PointD((rec.Left + rec.Right)/2, (rec.Top + rec.Bottom)/2);
end;
//------------------------------------------------------------------------------

function ArrowHead(const arrowTip, ctrlPt: TPointD; size: double;
  arrowStyle: TArrowStyle): TArrayOfPointD;
var
  unitVec, basePt: TPointD;
  sDiv2: double;
begin
  //controlPt: simply represents the direction of the line back from the tip
  //See also ShortenPath()
  sDiv2 := size * 0.5;
  unitVec := GetUnitVector(ctrlPt, arrowTip);
  case arrowStyle of
    asSimple:
      begin
        setLength(result, 3);
        basePt := OffsetPoint(arrowTip, -unitVec.X * size, -unitVec.Y * size);
        result[0] := arrowTip;
        result[1] := OffsetPoint(basePt, unitVec.Y * sDiv2, -unitVec.X * sDiv2);
        result[2] := OffsetPoint(basePt, -unitVec.Y * sDiv2, unitVec.X * sDiv2);
      end;
    asFancy:
      begin
        sDiv2 := sDiv2 * 0.75;
        setLength(result, 4);
        basePt := OffsetPoint(arrowTip,
          - 1.33 * unitVec.X * size, - 1.33 * unitVec.Y * size);
        result[0] := OffsetPoint(basePt, -unitVec.Y *sDiv2, unitVec.X *sDiv2);
        result[1] := OffsetPoint(arrowTip, -unitVec.X *size, -unitVec.Y *size);
        result[2] := OffsetPoint(basePt, unitVec.Y *sDiv2, -unitVec.X *sDiv2);
        result[3] := arrowTip;
      end;
    asDiamond:
      begin
        setLength(result, 4);
        basePt := OffsetPoint(arrowTip, -unitVec.X * sDiv2, -unitVec.Y * sDiv2);
        sDiv2 := sDiv2 * 0.75;
        result[0] := arrowTip;
        result[1] := OffsetPoint(basePt, unitVec.Y * sDiv2, -unitVec.X * sDiv2);
        result[2] := OffsetPoint(arrowTip, -unitVec.X * size, -unitVec.Y * size);
        result[3] := OffsetPoint(basePt, -unitVec.Y * sDiv2, unitVec.X * sDiv2);
      end;
    asCircle:
      begin
        basePt := OffsetPoint(arrowTip, -unitVec.X * sDiv2, -unitVec.Y * sDiv2);
        with Point(basePt) do
          result := Ellipse(RectD(x - sDiv2, y - sDiv2, x + sDiv2, y + sDiv2));
      end;
  end;
end;
//------------------------------------------------------------------------------

function ShortenPath(const path: TArrayOfPointD;
  pathEnd: TPathEnd; amount: double): TArrayOfPointD;
var
  len: double;
  vec: TPointD;
  highPath: integer;
begin
  result := path;
  highPath := high(path);
  if highPath < 1 then Exit;
  if pathEnd <> peEnd then
  begin
    while (highPath > 1) do
    begin
      len := Distance(path[0], path[1]);
      if (len >= amount) then Break;
      amount := amount - len;
      //Delete(result, 0, 1);
      Move(Result[1], Result[0], highPath * SizeOf(TPointD));
      SetLength(Result, highPath);
      dec(highPath);
    end;
    vec := GetUnitVector(path[0], path[1]);
    result[0].X := result[0].X + vec.X * amount;
    result[0].Y := result[0].Y + vec.Y * amount;
  end;
  if pathEnd <> peStart then
  begin
    while (highPath > 1) do
    begin
      len := Distance(path[highPath], path[highPath -1]);
      if (len >= amount) then Break;
      amount := amount - len;
      //Delete(result, highPath, 1);
      SetLength(Result, highPath);
      dec(highPath);
    end;
    vec := GetUnitVector(path[highPath], path[highPath -1]);
    result[highPath].X := result[highPath].X + vec.X * amount;
    result[highPath].Y := result[highPath].Y + vec.Y * amount;
  end;
end;
//------------------------------------------------------------------------------

function GetDashedPath(const path: TArrayOfPointD;
  closed: Boolean; const pattern: TArrayOfInteger;
  patternOffset: PDouble): TArrayOfArrayOfPointD;
var
  i, highI, paIdx: integer;
  vecs: TArrayOfPointD;
  patCnt, patLen, resCapacity, resCount: integer;
  segLen, residualPat, patOff: double;
  filling: Boolean;
  pt, pt2: TPointD;

  procedure AddDash(const pt1, pt2: TPointD);
  begin
    if resCount = resCapacity then
    begin
      inc(resCapacity, BuffSize);
      setLength(result, resCapacity);
    end;
    setLength( result[resCount], 2);
    Result[resCount][0] := pt1;
    Result[resCount][1] := pt2;
    inc(resCount);
  end;

begin
  paIdx := 0;
  patCnt := length(pattern);
  highI := high(path);
  if (highI < 1) or (patCnt = 0) then Exit;
  vecs := GetVectors(path);
  if (vecs[0].X = 0) and (vecs[0].Y = 0) then Exit; //not a line

  if not assigned(patternOffset) then
    patOff := 0 else
    patOff := patternOffset^;

  if patOff < 0 then
  begin
    patLen := 0;
    for i := 0 to patCnt -1 do inc(patLen, pattern[i]);
    patOff := patLen - patOff;
  end;
  resCapacity := 0;
  resCount := 0;
  paIdx := paIdx mod patCnt;

  filling := true;
  while patOff >= pattern[paIdx] do
  begin
    filling := not filling;
    patOff := patOff - pattern[paIdx];
    paIdx := (paIdx + 1) mod patCnt;
  end;
  residualPat := pattern[paIdx] - patOff;

  pt := path[0];
  i := 0;
  while (i < highI) do
  begin
    segLen := Distance(pt, path[i+1]);
    if residualPat > segLen then
    begin
      if filling then AddDash(pt, path[i+1]);
      residualPat := residualPat - segLen;
      pt := path[i+1];
      inc(i);
    end else
    begin
      pt2.X := pt.X + vecs[i].X * residualPat;
      pt2.Y := pt.Y + vecs[i].Y * residualPat;
      if filling then AddDash(pt, pt2);
      filling := not filling;
      paIdx := (paIdx + 1) mod patCnt;
      residualPat := pattern[paIdx];
      pt := pt2;
    end;
  end;

  if Closed then
    while true do
    begin
      segLen := Distance(pt, path[0]);
      if residualPat >= segLen then
      begin
        if filling then AddDash(pt, path[0]);
        break;
      end else
      begin
        pt2.X := pt.X + vecs[highI].X * residualPat;
        pt2.Y := pt.Y + vecs[highI].Y * residualPat;
        if filling then AddDash(pt, pt2);
        filling := not filling;
        paIdx := (paIdx + 1) mod patCnt;
        residualPat := pattern[paIdx];
        pt := pt2;
      end;
    end;
  SetLength(Result, resCount);

  if not assigned(patternOffset) then Exit;
  patOff := 0;
  for i := 0 to paIdx -1 do
    patOff := patOff + pattern[i];
  patternOffset^ := patOff + (pattern[paIdx] - residualPat);
end;
//------------------------------------------------------------------------------

function GetDashedOutLine(const path: TArrayOfPointD;
  closed: Boolean; const pattern: TArrayOfInteger;
  patternOffset: PDouble; lineWidth: double;
  joinStyle: TJoinStyle; endStyle: TEndStyle): TArrayOfArrayOfPointD;
var
  i: integer;
  tmp: TArrayOfArrayOfPointD;
begin
  Result := nil;
  tmp := GetDashedPath(path, closed, pattern, patternOffset);
  if closed then
    for i := 0 to high(tmp) do
      AppendPath(Result, GrowClosedLine(tmp[i],
        lineWidth, joinStyle, 2))
  else
    for i := 0 to high(tmp) do
      AppendPath(Result, GrowOpenLine(tmp[i],
        lineWidth, joinStyle, endStyle, 2));
end;
//------------------------------------------------------------------------------

function GetBoundsD(const paths: TArrayOfArrayOfPointD): TRectD;
var
  i,j: integer;
  l,t,r,b: double;
  ppd: PPointD;
begin
  l := MaxInt; t := MaxInt;
  r := -MaxInt; b := -MaxInt;
  for i := 0 to high(paths) do
  begin
    ppd := PPointD(paths[i]);
    if assigned(ppd) then
      for j := 0 to high(paths[i]) do
      begin
        if ppd.x < l then l := ppd.x;
        if ppd.x > r then r := ppd.x;
        if ppd.y < t then t := ppd.y;
        if ppd.y > b then b := ppd.y;
        inc(ppd);
      end;
  end;
  result := RectD(l, t, r, b);
end;
//------------------------------------------------------------------------------

function GetBoundsD(const path: TArrayOfPointD): TRectD;
var
  i,highI: integer;
  l,t,r,b: double;
  ppd: PPointD;
begin
  result := NullRectD;
  highI := High(path);
  if highI < 0 then Exit;
  l := path[0].X;
  t := path[0].Y;
  r := l;
  b := t;
  ppd := PPointD(path);
  for i := 1 to highI do
  begin
    inc(ppd);
    if ppd.x < l then l := ppd.x;
    if ppd.x > r then r := ppd.x;
    if ppd.y < t then t := ppd.y;
    if ppd.y > b then b := ppd.y;
  end;
  result := RectD(l, t, r, b);
end;
//------------------------------------------------------------------------------

function GetBounds(const path: TArrayOfPointD): TRect;
var
  recD: TRectD;
begin
  recD := GetBoundsD(path);
  Result := Rect(recD);
end;
//------------------------------------------------------------------------------

function GetBounds(const paths: TArrayOfArrayOfPointD): TRect;
var
  recD: TRectD;
begin
  recD := GetBoundsD(paths);
  Result := Rect(recD);
end;
//------------------------------------------------------------------------------

function QBezier(const pts: TArrayOfPointD): TArrayOfPointD;
begin
  if Length(pts) <> 3 then
    raise Exception.Create(rsInvalidQBezier);
  result := QBezier(pts[0], pts[1], pts[2]);
end;
//------------------------------------------------------------------------------

function QBezier(const pt1, pt2, pt3: TPointD): TArrayOfPointD;
var
  resultCnt, resultLen: integer;

  procedure AddPoint(const pt: TPointD);
  begin
    if resultCnt = resultLen then
    begin
      inc(resultLen, BuffSize);
      setLength(result, resultLen);
    end;
    result[resultCnt] := pt;
    inc(resultCnt);
  end;

  procedure DoCurve(const p1, p2, p3: TPointD);
  var
    p12, p23, p123: TPointD;
  begin
    if (abs(p1.x + p3.x - 2 * p2.x) +
      abs(p1.y + p3.y - 2 * p2.y) <
      QBezierTolerance) then //assessing curve 'flatness'
    begin
      AddPoint(p3);
    end else
    begin
      P12.X := (P1.X + P2.X) * 0.5;
      P12.Y := (P1.Y + P2.Y) * 0.5;
      P23.X := (P2.X + P3.X) * 0.5;
      P23.Y := (P2.Y + P3.Y) * 0.5;
      P123.X := (P12.X + P23.X) * 0.5;
      P123.Y := (P12.Y + P23.Y) * 0.5;
      DoCurve(p1, p12, p123);
      DoCurve(p123, p23, p3);
    end;
  end;

begin
  resultLen := 0; resultCnt := 0;
  AddPoint(pt1);
  DoCurve(pt1, pt2, pt3);
  SetLength(result, resultCnt);
end;
//------------------------------------------------------------------------------

function CBezier(const pts: TArrayOfPointD): TArrayOfPointD;
begin
  if Length(pts) <> 4 then
    raise Exception.Create(rsInvalidCBezier);
  result := CBezier(pts[0], pts[1], pts[2], pts[3]);
end;
//------------------------------------------------------------------------------

function CBezier(const pt1, pt2, pt3, pt4: TPointD): TArrayOfPointD;
var
  resultCnt, resultLen: integer;

  procedure AddPoint(const pt: TPointD);
  begin
    if resultCnt = resultLen then
    begin
      inc(resultLen, BuffSize);
      setLength(result, resultLen);
    end;
    result[resultCnt] := pt;
    inc(resultCnt);
  end;

  procedure DoCurve(const p1, p2, p3, p4: TPointD);
  var
    p12, p23, p34, p123, p234, p1234: TPointD;
  begin
    if (abs(p1.x + p3.x - 2*p2.x) + abs(p2.x + p4.x - 2*p3.x) +
      abs(p1.y + p3.y - 2*p2.y) + abs(p2.y + p4.y - 2*p3.y)) <
        CBezierTolerance then
    begin
      if resultCnt = length(result) then
        setLength(result, length(result) +BuffSize);
      result[resultCnt] := p4;
      inc(resultCnt);
    end else
    begin
      p12.X := (p1.X + p2.X) / 2;
      p12.Y := (p1.Y + p2.Y) / 2;
      p23.X := (p2.X + p3.X) / 2;
      p23.Y := (p2.Y + p3.Y) / 2;
      p34.X := (p3.X + p4.X) / 2;
      p34.Y := (p3.Y + p4.Y) / 2;
      p123.X := (p12.X + p23.X) / 2;
      p123.Y := (p12.Y + p23.Y) / 2;
      p234.X := (p23.X + p34.X) / 2;
      p234.Y := (p23.Y + p34.Y) / 2;
      p1234.X := (p123.X + p234.X) / 2;
      p1234.Y := (p123.Y + p234.Y) / 2;
      DoCurve(p1, p12, p123, p1234);
      DoCurve(p1234, p234, p34, p4);
    end;
  end;

begin
  result := nil;
  resultLen := 0; resultCnt := 0;
  AddPoint(pt1);
  DoCurve(pt1, pt2, pt3, pt4);
  SetLength(result,resultCnt);
end;
//------------------------------------------------------------------------------

function ReflectPoint(const pt, pivot: TPointD): TPointD;
begin
  Result.X := pivot.X + (pivot.X - pt.X);
  Result.Y := pivot.Y + (pivot.Y - pt.Y);
end;
//------------------------------------------------------------------------------

function CSpline(const pts: TArrayOfPointD): TArrayOfPointD;
var
  resultCnt, resultLen: integer;

  procedure AddPoint(const pt: TPointD);
  begin
    if resultCnt = resultLen then
    begin
      inc(resultLen, BuffSize);
      setLength(result, resultLen);
    end;
    result[resultCnt] := pt;
    inc(resultCnt);
  end;

  procedure DoCurve(const p1, p2, p3, p4: TPointD);
  var
    p12, p23, p34, p123, p234, p1234: TPointD;
  begin
    if (abs(p1.x + p3.x - 2*p2.x) + abs(p2.x + p4.x - 2*p3.x) +
      abs(p1.y + p3.y - 2*p2.y) + abs(p2.y + p4.y - 2*p3.y)) <
        CBezierTolerance then
    begin
      if resultCnt = length(result) then
        setLength(result, length(result) +BuffSize);
      result[resultCnt] := p4;
      inc(resultCnt);
    end else
    begin
      p12.X := (p1.X + p2.X) / 2;
      p12.Y := (p1.Y + p2.Y) / 2;
      p23.X := (p2.X + p3.X) / 2;
      p23.Y := (p2.Y + p3.Y) / 2;
      p34.X := (p3.X + p4.X) / 2;
      p34.Y := (p3.Y + p4.Y) / 2;
      p123.X := (p12.X + p23.X) / 2;
      p123.Y := (p12.Y + p23.Y) / 2;
      p234.X := (p23.X + p34.X) / 2;
      p234.Y := (p23.Y + p34.Y) / 2;
      p1234.X := (p123.X + p234.X) / 2;
      p1234.Y := (p123.Y + p234.Y) / 2;
      DoCurve(p1, p12, p123, p1234);
      DoCurve(p1234, p234, p34, p4);
    end;
  end;

var
  i, len: integer;
  p: PPointD;
  pt1,pt2,pt3,pt4: TPointD;
begin
  result := nil;
  len := Length(pts); resultLen := 0; resultCnt := 0;
  if (len < 4) then Exit;
  //ignore incomplete trailing control points
  if Odd(len) then dec(len);
  p := @pts[0];
  AddPoint(p^);
  pt1 := p^; inc(p);
  pt2 := p^; inc(p);
  for i := 0 to (len shr 1) - 2 do
  begin
    pt3 := p^; inc(p);
    pt4 := p^; inc(p);
    DoCurve(pt1, pt2, pt3, pt4);
    pt1 := pt4;
    pt2 := ReflectPoint(pt3, pt1);
  end;
  SetLength(result,resultCnt);
end;
//------------------------------------------------------------------------------

function QSpline(const pts: TArrayOfPointD): TArrayOfPointD;
var
  resultCnt, resultLen: integer;

  procedure AddPoint(const pt: TPointD);
  begin
    if resultCnt = resultLen then
    begin
      inc(resultLen, BuffSize);
      setLength(result, resultLen);
    end;
    result[resultCnt] := pt;
    inc(resultCnt);
  end;

  procedure DoCurve(const p1, p2, p3: TPointD);
  var
    p12, p23, p123: TPointD;
  begin
    if (abs(p1.x + p3.x - 2 * p2.x) +
      abs(p1.y + p3.y - 2 * p2.y) <
      QBezierTolerance) then //assessing curve 'flatness'
    begin
      AddPoint(p3);
    end else
    begin
      P12.X := (P1.X + P2.X) * 0.5;
      P12.Y := (P1.Y + P2.Y) * 0.5;
      P23.X := (P2.X + P3.X) * 0.5;
      P23.Y := (P2.Y + P3.Y) * 0.5;
      P123.X := (P12.X + P23.X) * 0.5;
      P123.Y := (P12.Y + P23.Y) * 0.5;
      DoCurve(p1, p12, p123);
      DoCurve(p123, p23, p3);
    end;
  end;

var
  i, len: integer;
  p: PPointD;
  pt1, pt2, pt3: TPointD;
begin
  result := nil;
  len := Length(pts); resultLen := 0; resultCnt := 0;
  if (len < 3) then Exit;
  p := @pts[0];
  AddPoint(p^);
  pt1 := p^; inc(p);
  pt2 := p^; inc(p);
  for i := 0 to len - 3 do
  begin
    pt3 := p^; inc(p);
    DoCurve(pt1, pt2, pt3);
    pt1 := pt3;
    pt2 := ReflectPoint(pt2, pt1);
  end;
  SetLength(result,resultCnt);
end;
//------------------------------------------------------------------------------

function MakePathI(const pts: array of integer): TArrayOfPointD; overload;
var
  i,j, x,y, len: Integer;
begin
  Result := nil;
  len := length(pts) div 2;
  if len < 1 then Exit;

  setlength(Result, len);
  Result[0].X := pts[0];
  Result[0].Y := pts[1];
  j := 0;
  for i := 1 to len -1 do
  begin
    x := pts[i*2];
    y := pts[i*2 +1];
    inc(j);
    Result[j].X := x;
    Result[j].Y := y;
  end;
  setlength(Result, j+1);
end;
//------------------------------------------------------------------------------

function MakePathD(const pts: array of double): TArrayOfPointD;
var
  i, j, len: Integer;
  x,y: double;
begin
  Result := nil;
  len := length(pts) div 2;
  if len < 1 then Exit;

  setlength(Result, len);
  Result[0].X := pts[0];
  Result[0].Y := pts[1];
  j := 0;
  for i := 1 to len -1 do
  begin
    x := pts[i*2];
    y := pts[i*2 +1];
    inc(j);
    Result[j].X := x;
    Result[j].Y := y;
  end;
  setlength(Result, j+1);
end;
//------------------------------------------------------------------------------

end.
