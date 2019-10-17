unit Unit1;

interface

//nb: Add Image32's Library folder to the project's search path
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Math,
  Types, Menus, ExtCtrls, ComCtrls, StdCtrls, Dialogs,
  BitmapPanels, Image32, Image32_Layers, Image32_MixedPath;

type
  TMoveType = (mtNone, mtAllButtons, mtOneButton,
    mtRotateButton, mtScaleButton, mtLayer);

  TFrmMain = class(TForm)
    pnlMain: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    mnuShowDesigner: TMenuItem;
    N1: TMenuItem;
    StatusBar1: TStatusBar;
    View1: TMenuItem;
    N2: TMenuItem;
    CopytoClipboard1: TMenuItem;
    PopupMenu1: TPopupMenu;
    mnuDeleteLayer: TMenuItem;
    N4: TMenuItem;
    mnuDeleteButton: TMenuItem;
    mnuEndEdit: TMenuItem;
    mnuDeleteAllButtonControls: TMenuItem;
    mnuEditLayer: TMenuItem;
    pnlTop: TPanel;
    N3: TMenuItem;
    mnuRotateButtons: TMenuItem;
    N5: TMenuItem;
    mnuSmoothSym: TMenuItem;
    mnuSmoothAsym: TMenuItem;
    mnuSharpWithHdls: TMenuItem;
    mnuSharpNoHdls: TMenuItem;
    rbLineArrow: TRadioButton;
    rbPolygonArrow: TRadioButton;
    mnuShowGrid: TMenuItem;
    mnuShowHatchedBackground: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    mnuLoadImage: TMenuItem;
    mnuRemoveImage: TMenuItem;
    Label2: TLabel;
    edWidth: TEdit;
    lblFillColor: TLabel;
    edFillColor: TEdit;
    lblPenColor: TLabel;
    edPenColor: TEdit;
    lblArrowStart: TLabel;
    lblArrowEnd: TLabel;
    cbArrowStart: TComboBox;
    cbArrowEnd: TComboBox;
    Label6: TLabel;
    LineWidthUpDown: TUpDown;
    SavetoFile1: TMenuItem;
    mnuScaleButtons: TMenuItem;
    Edit1: TMenuItem;
    mnuFinishEdit2: TMenuItem;
    mnuEditLayer2: TMenuItem;
    N6: TMenuItem;
    mnuRotateButtons2: TMenuItem;
    mnuScaleButtons2: TMenuItem;
    mnuDuplicateLayer: TMenuItem;
    mnuDuplicateLayer2: TMenuItem;
    mnuDeleteLayer2: TMenuItem;
    AddText1: TMenuItem;
    N7: TMenuItem;
    pnlText: TPanel;
    FontDialog1: TFontDialog;
    N8: TMenuItem;
    mnuFont2: TMenuItem;
    mnuFont: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pnlMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnlMainMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure pnlMainDblClick(Sender: TObject);
    procedure mnuEndEditClick(Sender: TObject);
    procedure mnuDeleteAllButtonControlsClick(Sender: TObject);
    procedure mnuEditLayerClick(Sender: TObject);
    procedure mnuDeleteLayerClick(Sender: TObject);
    procedure mnuDeleteButtonClick(Sender: TObject);
    procedure edWidthChange(Sender: TObject);
    procedure mnuRotateButtonsClick(Sender: TObject);
    procedure mnuTypeChangeClick(Sender: TObject);
    procedure rbLineArrowClick(Sender: TObject);
    procedure mnuShowGridClick(Sender: TObject);
    procedure mnuLoadImageClick(Sender: TObject);
    procedure mnuRemoveImageClick(Sender: TObject);
    procedure SavetoFile1Click(Sender: TObject);
    procedure mnuDuplicateLayerClick(Sender: TObject);
    procedure AddText1Click(Sender: TObject);
    procedure mnuFontClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure edPenColorChange(Sender: TObject);
  private
    layeredImage32: TLayeredImage32;
    clickPoint    : TPoint;
    rotPoint      : TPoint;
    moveType      : TMoveType;
    clickedLayer  : TLayer32;
    designLayer   : TLayer32;
    buttonPath    : TSmoothPath;
    dist          : double;
    btnPathRegion : TArrayOfArrayOfPointD;
    dashes        : TArrayOfInteger;
    disableTypeChangeClick : Boolean;
    procedure RefreshButtonPositionsFromPath;
    procedure UpdateButtonGroupFromPath;
    function HitTestButtonPath(const pt: TPoint): Boolean;
    procedure BeginPanelPaint(Sender: TObject);
    procedure UpdateLayeredImage;
    procedure StartPolygonArrow;
    function ClearRotateSizeButton: Boolean;
    procedure UpdateMenus;
    procedure DisplayFont;
    function ShortenPathAndGetArrowHeads(var path: TArrayOfPointD):
      TArrayOfArrayOfPointD;
    procedure AdjustArrow(index: integer; newPt: TPointD);
    procedure PanelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    { Public declarations }
  end;

  TLineLayer32 = class(TSmoothPathLayer32)
  public
    procedure SetSmoothPathAndDraw(const smoothPath: TSmoothPath);
  end;

  TPolygonLayer32 = class(TSmoothPathLayer32)
  public
    procedure SetSmoothPathAndDraw(const smoothPath: TSmoothPath);
  end;

  TTextLayer32 = class(TLayer32)
  public
    procedure PositionTextAndDraw(const pt: TPoint);
  end;

var
  FrmMain: TFrmMain;
  penColor, fillColor: TColor32;

implementation

{$R *.dfm}
{$R Cursors.res}

uses
  Image32_BMP, Image32_PNG, Image32_JPG, Image32_Draw, Image32_Vector,
  Image32_Extra, Image32_Text, Image32_Clipper;

const
  crRotate = 1;
  crMove = 2;
  crMove2 = 3;
  margin = 100;
  defaultFillClr: TColor32 = $80FFFF00;
  defaultPenClr : TColor32 = $FF000000;
var
  buttonSize   : integer;
  hitTestWidth : integer;
  lineWidth    : integer;
  popupPos     : TPoint;

type

  TExButtonDesignerLayer32 = class(TButtonDesignerLayer32)
  public
    PointType: TSmoothType; //point type for curve end controls
  end;

//------------------------------------------------------------------------------
// TLineLayer32
//------------------------------------------------------------------------------

//save a copy of smoothPath (in case of later editing) and
//also draw the completed line and arrows on the layer's image
procedure TLineLayer32.SetSmoothPathAndDraw(const smoothPath: TSmoothPath);
var
  rec: TRect;
  flatPath: TArrayOfPointD;
  paths: TArrayOfArrayOfPointD;
begin
  self.SmoothPath.Assign(smoothPath);
  CursorId := crMove;

  flatPath := smoothPath.FlattenedPath;
  paths := FrmMain.ShortenPathAndGetArrowHeads(flatPath);

  //nb: flatpath may have been shortened by GetArrowHeads above
  AppendPath(paths, OpenPathToFlatPolygon(flatPath));
  HitTestRegions :=
    InflatePolygons(paths, (lineWidth + hitTestWidth) * 0.5, jsAuto);

  //now remove inflated flatpath that was just added to paths
  SetLength(paths, Length(paths) -1);

  //draw flattened line
  rec := GetBounds(HitTestRegions);
  self.SetBounds(rec);

  flatPath := OffsetPath(flatPath, -Left, -Top);
  paths := OffsetPath(paths, -Left, -Top);
  Image.Clear;
  DrawPolygon(Image, paths, frEvenOdd, fillColor);
  DrawLine(Image, flatPath, lineWidth, penColor, esRound);
  DrawLine(Image, paths, lineWidth, penColor, esClosed);
end;

//------------------------------------------------------------------------------
// TPolygonLayer32
//------------------------------------------------------------------------------

//save a copy of smoothPath (in case of later editing) and
//also draw the completed polygon on the layer's image
procedure TPolygonLayer32.SetSmoothPathAndDraw(const smoothPath: TSmoothPath);
var
  rec: TRect;
  flattened: TArrayOfPointD;
begin
  //calculate and assign hit test regions
  flattened := smoothPath.FlattenedPath;
  //nb: UnionPolygon fixes up any self-intersections
  self.HitTestRegions := UnionPolygon(flattened, frEvenOdd);
  HitTestRegions :=
    InflatePolygons(HitTestRegions, (lineWidth + hitTestWidth) *0.5);

  self.SmoothPath.Assign(smoothPath);
  CursorId := crMove;

  //draw polygon
  rec := GetBounds(HitTestRegions);
  self.SetBounds(rec);
  flattened := OffsetPath(flattened, -Left, -Top);
  Image.Clear;
  DrawPolygon(Image, flattened, frNonZero, fillColor);
  DrawLine(Image, flattened, lineWidth, penColor, esClosed);
end;

//------------------------------------------------------------------------------
// TTextLayer32
//------------------------------------------------------------------------------

procedure TTextLayer32.PositionTextAndDraw(const pt: TPoint);
var
  rec: TRectD;
  rec2: TRect;
  charOffsets: TArrayOfPointD;
  htwDiv2: integer;
begin
  MeasureText(name, nil, rec, charOffsets);
  rec2 := Rect(rec);
  htwDiv2 := hitTestWidth div 2;
  Windows.InflateRect(rec2, htwDiv2, htwDiv2);
  Windows.OffsetRect(rec2, pt.X, pt.Y);
  SetBounds(rec2);
  DrawText(Image, htwDiv2 +rec.Left, htwDiv2 -rec.top, name, nil, taLeft, penColor);
end;

//------------------------------------------------------------------------------
// TFrmMain
//------------------------------------------------------------------------------

procedure TFrmMain.FormCreate(Sender: TObject);
var
  layer: TLayer32;
  rec: TRect;
begin
  lineWidth          := DPI(5);
  LineWidthUpDown.Position := lineWidth;
  hitTestWidth       := DPI(5);
  buttonSize         := DPI(9);
  popupPos           := Types.Point(0,0);

  fillColor          := defaultFillClr;
  penColor           := defaultPenClr;
  edFillColor.Text   := '$' + inttoHex(fillColor, 8);
  edPenColor.Text    := '$' + inttoHex(penColor, 8);

  setLength(dashes, 2);
  dashes[0] := 5; dashes[1] := 5;
  buttonPath := TSmoothPath.Create;

  with pnlTop do
  begin
    Bitmap.Width := RectWidth(InnerClientRect);
    Bitmap.Height := RectHeight(InnerClientRect);
    BitmapProperties.AutoCenter := false;
  end;

  //SETUP THE DISPLAY PANEL
  pnlMain.BorderWidth := DPI(16);
  pnlMain.BevelInner := bvLowered;
  //set pnlMain.Tabstop -> true to enable keyboard controls
  pnlMain.TabStop := true;
  pnlMain.FocusedColor := clGradientInactiveCaption;
  pnlMain.BitmapProperties.Scale := 1;
  pnlMain.BitmapProperties.OnBeginPaint := BeginPanelPaint;
  pnlMain.BitmapProperties.OnKeyDown := PanelKeyDown;
  pnlMain.Bitmap.PixelFormat := pf32bit; //for alpha transparency

  //SETUP LAYEREDIMAGE32
  rec := pnlMain.InnerClientRect;
  layeredImage32 := TLayeredImage32.Create(RectWidth(rec), RectHeight(rec));

  //hatched image layer is TDesignerLayer32 so it's 'non-clickable'
  layer := layeredImage32.AddNewLayer(TDesignerLayer32, 'hatched background');
  layer.SetSize(layeredImage32.Width, layeredImage32.Height);
  HatchBackground(layer.Image);

  //layer for an opened image
  layer := layeredImage32.AddNewLayer('loaded image ');
  layer.CursorId := crMove2; //custom move cursor
  layer.Visible := false;

  //and another designer layer
  designLayer := layeredImage32.AddNewLayer(TDesignerLayer32, 'designer');
  designLayer.SetSize(layeredImage32.Width, layeredImage32.Height);

  Screen.Cursors[crRotate] :=
    LoadImage(hInstance, 'ROTATE', IMAGE_CURSOR, 0,0, LR_DEFAULTSIZE);
  Screen.Cursors[crMove] :=
    LoadImage(hInstance, 'MOVE', IMAGE_CURSOR, 0,0, LR_DEFAULTSIZE);
  Screen.Cursors[crMove2] :=
    LoadImage(hInstance, 'MOVE2', IMAGE_CURSOR, 0,0, LR_DEFAULTSIZE);

  UpdateMenus;
  DisplayFont;
  edPenColorChange(nil);
end;
//------------------------------------------------------------------------------

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  buttonPath.Free;
  layeredImage32.Free;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.RefreshButtonPositionsFromPath;
var
  i, fig,lig: integer;
begin
  //nb: Group '1' is always the button designer group
  fig := layeredImage32.GetFirstInGroupIdx(1);
  if fig < 0 then Exit;
  lig := layeredImage32.GetLastInGroupIdx(1);

  for i := fig to lig do
    layeredImage32[i].PositionCenteredAt(buttonPath[i-fig]);

  //update hittest region too
  if buttonPath.Count < 2 then
    btnPathRegion := nil
  else if rbPolygonArrow.Checked then
    btnPathRegion := InflatePolygon(buttonPath.FlattenedPath,
      (lineWidth + hitTestWidth) * 0.5, jsRound)
  else
    btnPathRegion := InflateOpenPath(OpenPathToFlatPolygon(
      buttonPath.FlattenedPath), lineWidth + hitTestWidth, jsRound);
end;
//------------------------------------------------------------------------------

procedure TFrmMain.UpdateButtonGroupFromPath;
var
  i: integer;
  hideNextLayer, IsNode: Boolean;
  layer: TLayer32;
  btnColor: TColor32;
const
  //There are 2 types of CBezier buttons controls:
  //1. curve ends and 2. curve shape controls (aka handles)
  btnColors: array [boolean] of TColor32 = ($FF0088FF, $FF00AA00);
  buttonOpts: array [boolean] of TButtonOptions = ([], [boSquare]);
  btnColorLast: TColor32 = clLime32;
begin
  layeredImage32.DeleteGroup(1);

  if buttonPath.Count = 0  then
  begin
    btnPathRegion := nil;
    UpdateMenus;
    Exit;
  end;


  if buttonPath.Count = 1 then btnColor := btnColorLast else btnColor := btnColors[true];
  layer := StartButtonGroup(layeredImage32,
    Point(buttonPath[0]), btnColor, buttonSize, buttonOpts[true],
    TExButtonDesignerLayer32);
  with TExButtonDesignerLayer32(layer) do
  begin
    PointType := buttonPath.PointTypes[0];
    hideNextLayer := (PointType = stSharpNoHdls);
  end;

  //re IsNode: a bezier control 'node' is always on the path (and at each end
  //of a bezier sub-curve) whereas a control 'handle' merely shapes the path.
  //Nodes and handles are shaped and colored distinctively here
  for i := 1 to buttonPath.Count -1 do
  begin
      IsNode := i mod 3 = 0;
      if i = buttonPath.Count - 1 then
        btnColor := btnColorLast else
        btnColor := btnColors[IsNode];
      layer := AddToButtonGroup(layeredImage32, 1, Point(buttonPath[i]),
        btnColor, buttonSize, buttonOpts[IsNode]);
      with TExButtonDesignerLayer32(layer) do
      begin
        PointType := buttonPath.PointTypes[i];
        Visible := not hideNextLayer;
        if IsNode and (PointType = stSharpNoHdls) then
        begin
          layeredImage32[layer.Index -1].Visible := false;
          hideNextLayer := True;
        end
        else hideNextLayer := false;
      end;
  end;

  //update hittest region too
  if buttonPath.Count < 2 then
    btnPathRegion := nil
  else if rbPolygonArrow.Checked then
    btnPathRegion := InflatePolygon(buttonPath.FlattenedPath,
      (lineWidth + hitTestWidth) * 0.5, jsRound)
  else
    btnPathRegion := InflateOpenPath(OpenPathToFlatPolygon(
      buttonPath.FlattenedPath), lineWidth + hitTestWidth, jsRound);
  UpdateMenus;
end;
//------------------------------------------------------------------------------

function TFrmMain.HitTestButtonPath(const pt: TPoint): Boolean;
begin
  result := PointInPolygons(PointD(pt), btnPathRegion, frEvenOdd);
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuDeleteButtonClick(Sender: TObject);
begin
  //delete last bezier sub-curve
  if (layeredImage32.TopLayer.GroupId <> 1) or
    rbPolygonArrow.Checked then Exit;
  buttonPath.DeleteLast;
  UpdateButtonGroupFromPath;
  clickedLayer := nil;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuDeleteAllButtonControlsClick(Sender: TObject);
begin
  ClearRotateSizeButton;
  if layeredImage32.GroupCount(1) = 0 then Exit;
  layeredImage32.DeleteGroup(1);
  buttonPath.Clear;
  clickedLayer := nil;
  btnPathRegion := nil;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

function TFrmMain.ShortenPathAndGetArrowHeads(var path: TArrayOfPointD):
  TArrayOfArrayOfPointD;
var
  pt1, pt2: TPointD;
  pathEnd: TPathEnd;
  arrowSize: double;
begin
  Result := nil;
  if (cbArrowStart.ItemIndex = 0) and (cbArrowEnd.ItemIndex = 0) then Exit;

  if (cbArrowStart.ItemIndex > 0) and (cbArrowEnd.ItemIndex > 0) then
    pathEnd := peBothEnds
  else if (cbArrowStart.ItemIndex > 0) then
    pathEnd := peStart
  else
    pathEnd := peEnd;
  arrowSize := GetDefaultArrowHeadSize(lineWidth);
  pt1 := path[0]; pt2 := path[High(path)];
  path := ShortenPath(path, pathEnd, arrowSize);
  case pathEnd of
    peStart: AppendPath(Result, ArrowHead(pt1, path[0],
      arrowSize, TArrowStyle(cbArrowStart.ItemIndex)));
    peEnd: AppendPath(Result, ArrowHead(pt2,path[High(path)],
      arrowSize, TArrowStyle(cbArrowEnd.ItemIndex)));
    else
      begin
        AppendPath(Result, ArrowHead(pt1, path[0],
          arrowSize, TArrowStyle(cbArrowStart.ItemIndex)));
        AppendPath(Result, ArrowHead(pt2, path[High(path)],
          arrowSize, TArrowStyle(cbArrowEnd.ItemIndex)));
      end;
  end;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.UpdateLayeredImage;
var
  i, d: integer;
  rec: TRect;
  flatPath: TArrayOfPointD;
  arrowHeads: TArrayOfArrayOfPointD;
  dl: TDesignerLayer32;
  penClr: TColor32;
const
  fillC: TColor32 = $40AAAAAA;
  penC: TColor32 = $AAFF0000;
begin
  if not Active then Exit; //just avoids several calls in FormCreate

  //Repaints the designer layer
  dl := TDesignerLayer32(designLayer);
  dl.Image.Clear;

  //designer (non-rotation, non-scaling) buttons
  //though most of this is just arrow head stuff
  flatPath := buttonPath.FlattenedPath;
  if Assigned(flatPath) then
  begin
    if buttonPath.CurrentCurveIsComplete then
      penClr := penColor else
      penClr := $FFCC0000; //red

    //draw plain old flattened button path
    if rbPolygonArrow.Checked then
    begin
      DrawPolygon(dl.Image, flatPath, frEvenOdd, fillColor);
      DrawLine(dl.Image, flatPath, lineWidth, penClr, esClosed);
    end else
    begin
      arrowHeads := ShortenPathAndGetArrowHeads(flatPath);
      DrawPolygon(dl.Image, arrowHeads, frEvenOdd, fillColor);
      DrawLine(dl.Image, arrowHeads, lineWidth, penClr, esClosed);
      DrawLine(dl.Image, flatPath, lineWidth, penClr, esRound);
    end;
    //display control lines
    DrawSmoothPathDesigner(buttonPath, dl);
  end;

  //outline selected button
  if Assigned(clickedLayer) and (clickedLayer is TButtonDesignerLayer32) then
  begin
    rec.TopLeft := Point(clickedLayer.MidPoint);
    rec.BottomRight := rec.TopLeft;
    i := Max(DefaultButtonSize, linewidth) div 2 + hitTestWidth;
    Windows.InflateRect(rec, i, i);
    DrawPolygon(dl.Image, Ellipse(rec), frEvenOdd, fillC);
    DrawLine(dl.Image, Ellipse(rec), 1, penC, esClosed);
  end;

  //scaling or rotation (always group 2)
  i := layeredImage32.GetFirstInGroupIdx(2);
  if i > 0 then
  begin
    DrawButton(dl.Image, PointD(rotPoint), DefaultButtonSize, clSilver32);
    d := Round(Distance(Point(layeredImage32.TopLayer.MidPoint), rotPoint));
    with rotPoint do rec := Rect(X - d, Y - d, X + d, Y + d);
    dl.DrawEllipse(rec);
  end;

  //display dashed hit-test outline for selected layer
  if Assigned(clickedLayer) then
  begin
    if (clickedLayer is TSmoothPathLayer32) then
      DrawDashedLine(dl.Image, clickedLayer.HitTestRegions,
        dashes, nil, 1, clRed32, esClosed)
    else if (clickedLayer is TTextLayer32) then
      DrawDashedLine(dl.Image, Rectangle(clickedLayer.Bounds),
        dashes, nil, 1, clRed32, esClosed)
  end;

  //and update the statusbar too
  if assigned(clickedLayer) and (clickedLayer.GroupId = 1) then
  begin
    with clickedLayer.MidPoint do
    begin
      if (clickedLayer.IndexInGroup mod 3 = 0) then
      begin
        case TExButtonDesignerLayer32(clickedLayer).PointType of
          stSmoothSym: StatusBar1.SimpleText :=
              format(' Smooth - symmetric (%1.0n,%1.0n)',[X,Y]);
          stSmoothAsym: StatusBar1.SimpleText :=
              format(' Smooth - asymmetric (%1.0n,%1.0n)',[X,Y]);
          stSharpWithHdls: StatusBar1.SimpleText :=
              format(' Sharp - with handles (%1.0n,%1.0n)',[X,Y]);
          else
            StatusBar1.SimpleText :=
              format(' Sharp - without handles (%1.0n,%1.0n)',[X,Y]);
        end;
      end else
      StatusBar1.SimpleText := format(' (%1.0n,%1.0n)',[X,Y]);
    end;
  end else
    StatusBar1.SimpleText := '';

  pnlMain.Invalidate;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.BeginPanelPaint(Sender: TObject);
var
  dc: HDC;
begin
  //update pnlMain.Bitmap with layeredImage32's merged image
  {$IFDEF SETSIZE}
  pnlMain.Bitmap.SetSize(layeredImage32.Width, layeredImage32.Height);
  {$ELSE}
  pnlMain.Bitmap.Width := layeredImage32.Width;
  pnlMain.Bitmap.Height := layeredImage32.Height;
  {$ENDIF}
  dc := pnlMain.Bitmap.Canvas.Handle;
  layeredImage32.GetMergedImage(not mnuShowDesigner.Checked).CopyToDc(dc,0,0,false);
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuEndEditClick(Sender: TObject);
var
  polygonLayer: TPolygonLayer32;
  lineLayer: TLineLayer32;
begin
  //convert the designer path into a completed open poly-line (+/- arrows)
  //or into a completed arrow polygon

  if not buttonPath.CurrentCurveIsComplete or
    not (layeredImage32.TopLayer is TButtonDesignerLayer32) then Exit;
  try
    //just in case the rotation/scaling button is active ...
    ClearRotateSizeButton;

    //create a 'completed' path (polyline or polygon) from the buttons
    if rbPolygonArrow.Checked then
    begin
      layeredImage32.DeleteGroup(1);
      polygonLayer :=
        TPolygonLayer32(layeredImage32.AddNewLayer(TPolygonLayer32, 'polygon'));
      polygonLayer.SetSmoothPathAndDraw(buttonPath);
      designLayer.BringForward(polygonLayer.Index);
    end else
    begin
      if buttonPath.Count < 2 then Exit;
      layeredImage32.DeleteGroup(1);
      lineLayer :=
        TLineLayer32(layeredImage32.AddNewLayer(TLineLayer32, 'line'));
      lineLayer.SetSmoothPathAndDraw(buttonPath);
      designLayer.BringForward(lineLayer.Index);
    end;
  finally
    buttonPath.Clear;
    btnPathRegion := nil;
    clickedLayer := nil;
    UpdateLayeredImage;
    UpdateMenus;
  end;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuEditLayerClick(Sender: TObject);
begin
  //re-edit a 'completed' line or polygon arrow layer
  if not assigned(clickedLayer) or
    not (clickedLayer is TSmoothPathLayer32) then Exit;

  //When 'editing' a layer (line or polygon), delete any buttons first
  if layeredImage32.GroupCount(1) > 0 then
    layeredImage32.DeleteGroup(1);

  buttonPath.Assign(TSmoothPathLayer32(clickedLayer).SmoothPath);

  //finally delete the selected layer now we have the edit buttons
  layeredImage32.DeleteLayer(clickedLayer.Index);
  clickedLayer := nil;
  UpdateButtonGroupFromPath;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuRotateButtonsClick(Sender: TObject);
var
  rec: TRect;
  pt: TPointD;
  i: integer;
  layer: TLayer32;
begin
  if (buttonPath.Count < 2) then Exit;
  ClearRotateSizeButton;
  rec := GetBounds(buttonPath.CtrlPoints);
  rotPoint := MidPoint(rec);
  i := (RectWidth(rec) + RectHeight(rec)) div 3;
  pt := PointD(rotPoint.X, rotPoint.Y - i);
  if (Sender = mnuRotateButtons) or (Sender = mnuRotateButtons2) then
  begin
    layer := StartButtonGroup(layeredImage32, Point(pt), clRed32,
      DPI(9), [], TButtonDesignerLayer32);
    layer.CursorId := crRotate;
    layer.Name := 'Rotate';
  end else
  begin
    dist := i;
    layer := StartButtonGroup(layeredImage32, Point(pt), clLime32,
      DPI(9), [], TButtonDesignerLayer32);
    layer.CursorId := crSizeNS;
    layer.Name := 'Scale';
  end;
  clickedLayer := layer;
  clickPoint := Point(pt);
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.pnlMainDblClick(Sender: TObject);
begin
  //double click:
  //  when 'polygon arrow' selected - start a new one
  //  when 'line arrow' selected - start or add another 'node' button
  if rbPolygonArrow.Checked then
  begin
    if layeredImage32.GroupCount(1) > 0 then Exit;
    StartPolygonArrow;
  end else
    buttonPath.Add(PointD(clickPoint), buttonPath.LastType);
  UpdateButtonGroupFromPath;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.pnlMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
  clickedLayer := nil;
  moveType := mtNone;

  //convert pnlMain client coordinates to bitmap coordinates
  pt := Types.Point(X,Y);
  if not pnlMain.ClientToBitmap(pt) then Exit;
  clickPoint := pt;

  //get the layer that was clicked (if any)
  clickedLayer := layeredImage32.GetLayerAt(pt);

  if not Assigned(clickedLayer) then
  begin
    if HitTestButtonPath(pt) then moveType := mtAllButtons;
  end
  else if (clickedLayer is TButtonDesignerLayer32) then
  begin
    if clickedLayer.GroupId = 1 then
      moveType := mtOneButton
    else if clickedLayer.Name = 'Scale' then
      moveType := mtScaleButton
    else
      moveType := mtRotateButton;
  end
  //the design path takes precedence over a 'completed' layer or a loaded image
  else if HitTestButtonPath(pt) then
    moveType := mtAllButtons
  else
    moveType := mtLayer; //a completed layer (line or polygon) or loaded image

  //just in case the rotation/scaling button is still active ...
  if not (moveType in [mtRotateButton, mtScaleButton]) then
    ClearRotateSizeButton;

  //disable pnlMain scrolling if we're about to move a layer
  pnlMain.BitmapProperties.ZoomAndScrollEnabled := moveType = mtNone;

  UpdateLayeredImage;
  UpdateMenus;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.AdjustArrow(index: integer; newPt: TPointD);
var
  pt, pt2, vec: TPointD;
  dist: Double;
begin
  //AdjustArrow - constrains the polygon arrow to a sensible shape
  //(ie preserves symmetry and avoids self-intersections etc)
  pt := MidPoint(buttonPath[3*3],buttonPath[4*3]);
  case index of
    0:
      begin
        newPt := ClosestPointOnLine(newPt, buttonPath[0], pt);
        if (CrossProduct(newPt, buttonPath[1*3], buttonPath[6*3]) > 0) and
          (CrossProduct(newPt, buttonPath[1*3], buttonPath[2*3]) > 0) then
          buttonPath[0] := newPt;
      end;
    1:
      begin
        dist := Distance(buttonPath[2*3], buttonPath[5*3]) * 0.5;
        pt2 := ClosestPointOnLine(newPt, buttonPath[0], pt);
        if (DotProduct(newPt, pt, buttonPath[0]) <= 0) or
          (DotProduct(newPt, buttonPath[0], pt) <= 0) or
          (Distance(newPt, pt2) <= dist) then Exit;
        buttonPath[1*3] := newPt;
        buttonPath[6*3] := ReflectPoint(newPt, pt2);
        if (CrossProduct(newPt, buttonPath[2*3], buttonPath[0]) > 0) and
          (CrossProduct(newPt, buttonPath[2*3], buttonPath[5*3]) <= 0) and
          (CrossProduct(newPt, buttonPath[2*3], buttonPath[3*3]) < 0) then Exit;
        vec := GetUnitVector(pt2, buttonPath[1*3]);
        buttonPath[2*3] := PointD(pt2.X + vec.X * dist, pt2.Y + vec.Y * dist);
        buttonPath[5*3] := PointD(pt2.X + vec.X * -dist, pt2.Y + vec.Y * -dist);
      end;
    2:
      begin
        if (CrossProduct(newPt, buttonPath[1*3], buttonPath[0]) >= 0) or
          (CrossProduct(buttonPath[1*3], newPt, buttonPath[3*3]) >= 0) or
          (CrossProduct(newPt, buttonPath[3*3], buttonPath[4*3]) <= 0) or
          (CrossProduct(buttonPath[0], newPt, pt) <= 0) then Exit;
        buttonPath[2*3] := newPt;
        pt2 := ClosestPointOnLine(newPt, buttonPath[0], pt);
        buttonPath[5*3] := ReflectPoint(newPt, pt2);
        if CrossProduct(buttonPath[1*3], newPt, buttonPath[6*3]) <= 0 then Exit;
        dist := Distance(buttonPath[1*3], buttonPath[6*3]) * 0.5;
        vec := GetUnitVector(pt2, newPt);
        buttonPath[1*3] := PointD(pt2.X + vec.X * dist, pt2.Y + vec.Y * dist);
        buttonPath[6*3] := PointD(pt2.X + vec.X * -dist, pt2.Y + vec.Y * -dist);
      end;
    3:
      begin
        if (CrossProduct(newPt, buttonPath[0], pt) > 0) or
          (CrossProduct(buttonPath[1*3], buttonPath[2*3], newPt) >= 0) then Exit;
        buttonPath[3*3] := newPt;
        pt := ClosestPointOnLine(newPt, buttonPath[0], pt);
        buttonPath[4*3] := ReflectPoint(newPt, pt);
      end;
    4:
      begin
        if (CrossProduct(newPt, buttonPath[0], pt) < 0) or
          (CrossProduct(buttonPath[6*3], buttonPath[5*3], newPt) <= 0) then Exit;
        buttonPath[4*3] := newPt;
        pt := ClosestPointOnLine(newPt, buttonPath[0], pt);
        buttonPath[3*3] := ReflectPoint(newPt, pt);
      end;
    5:
      begin
        if (CrossProduct(newPt, buttonPath[6*3], buttonPath[0]) <= 0) or
          (CrossProduct(buttonPath[6*3], newPt, buttonPath[4*3]) <= 0) or
          (CrossProduct(newPt, buttonPath[4*3], buttonPath[3*3]) >= 0) or
          (CrossProduct(buttonPath[0], newPt, pt) >= 0) then Exit;
        buttonPath[5*3] := newPt;
        pt2 := ClosestPointOnLine(newPt, buttonPath[0], pt);
        buttonPath[2*3] := ReflectPoint(newPt, pt2);
        if CrossProduct(buttonPath[6*3], newPt, buttonPath[1*3]) >= 0 then Exit;
        dist := Distance(buttonPath[6*3], buttonPath[1*3]) * 0.5;
        vec := GetUnitVector(pt2, newPt);
        buttonPath[6*3] := PointD(pt2.X + vec.X * dist, pt2.Y + vec.Y * dist);
        buttonPath[1*3] := PointD(pt2.X + vec.X * -dist, pt2.Y + vec.Y * -dist);
      end;
    6:
      begin
        dist := Distance(buttonPath[5*3], buttonPath[2*3]) * 0.5;
        pt2 := ClosestPointOnLine(newPt, buttonPath[0], pt);
        if (DotProduct(newPt, pt, buttonPath[0]) <= 0) or
          (DotProduct(newPt, buttonPath[0], pt) <= 0) or
          (Distance(newPt, pt2) <= dist) then Exit;
        buttonPath[6*3] := newPt;
        buttonPath[1*3] := ReflectPoint(newPt, pt2);
        if (CrossProduct(newPt, buttonPath[5*3], buttonPath[0]) < 0) and
          (CrossProduct(newPt, buttonPath[5*3], buttonPath[2*3]) >= 0) and
          (CrossProduct(newPt, buttonPath[5*3], buttonPath[4*3]) > 0) then Exit;
        vec := GetUnitVector(pt2, buttonPath[6*3]);
        buttonPath[5*3] := PointD(pt2.X + vec.X * dist, pt2.Y + vec.Y * dist);
        buttonPath[2*3] := PointD(pt2.X + vec.X * -dist, pt2.Y + vec.Y * -dist);
      end;
  end;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.pnlMainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  dx,dy: integer;
  pt, pt2: TPoint;
  layer: TLayer32;
  dist1, scale, angle: double;
  rec: TRect;
begin
  pt := Types.Point(X,Y);
  if not pnlMain.ClientToBitmap(pt) then
  begin
    pnlMain.Cursor := crDefault;
    Exit;
  end;

  if moveType = mtNone then
  begin
    //just update the cursor
    layer := layeredImage32.GetLayerAt(pt);
    if Assigned(layer) and (layer is TButtonDesignerLayer32) then
      pnlMain.Cursor := layer.CursorId
    else if HitTestButtonPath(pt) then
      pnlMain.Cursor := crMove
    else if Assigned(layer) then
      pnlMain.Cursor := layer.CursorId
    else
      pnlMain.Cursor := crDefault;
    Exit;
  end;

  //moving either one or all buttons, or a completed layer
  dx := pt.X - clickPoint.X;
  dy := pt.Y - clickPoint.Y;
  case moveType of
    mtAllButtons:
      begin
        buttonPath.Offset(dx, dy);
        RefreshButtonPositionsFromPath;
      end;
    mtOneButton:
      begin
        if rbPolygonArrow.Checked then
        begin
          AdjustArrow(clickedLayer.IndexInGroup div 3, PointD(pt));
        end else
          buttonPath[clickedLayer.IndexInGroup] := PointD(pt);
        RefreshButtonPositionsFromPath;
      end;
    mtRotateButton:
      begin
        clickedLayer.Offset(dx, dy);
        angle := GetAngle(clickPoint, rotPoint, pt);
        buttonPath.Rotate(PointD(rotPoint), angle);
        RefreshButtonPositionsFromPath;
      end;
    mtScaleButton:
      begin
        clickedLayer.Offset(0, dy);
        dist1 := Abs(pt.Y - rotPoint.Y);
        if dist1 < 10 then Exit;
        scale := dist1/dist;
        dist := dist1;
        buttonPath.Scale(scale, scale);
        rec := GetBounds(buttonPath.CtrlPoints);
        pt2 := MidPoint(Rec);
        buttonPath.Offset(rotPoint.X - pt2.X, rotPoint.Y - pt2.Y);
        RefreshButtonPositionsFromPath;
        pt.X := rotPoint.X;
      end;
    else
      clickedLayer.Offset(dx, dy);
  end;
  clickPoint := pt;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.pnlMainMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  moveType := mtNone;
  //re-enable pnlMain zoom and scroll
  pnlMain.BitmapProperties.ZoomAndScrollEnabled := true;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuDuplicateLayerClick(Sender: TObject);
var
  dup: TLayer32;
begin
  if not Assigned(clickedLayer) or
    (not (clickedLayer is TSmoothPathLayer32) and
    not (clickedLayer is TTextLayer32)) then Exit;

  //just in case the rotation/scaling button is active ...
  ClearRotateSizeButton;

  if clickedLayer is TTextLayer32 then
  begin
    dup  := layeredImage32.InsertNewLayer(TTextLayer32,
      clickedLayer.Index +1, clickedLayer.Name);
    TTextLayer32(dup).PositionTextAndDraw(clickedLayer.Bounds.TopLeft);
  end
  else if clickedLayer is TPolygonLayer32 then
  begin
    dup  := layeredImage32.InsertNewLayer(TPolygonLayer32,
      clickedLayer.Index +1, 'polygon');
    TPolygonLayer32(dup).SetSmoothPathAndDraw(
      TPolygonLayer32(clickedLayer).SmoothPath);
  end else
  begin
    dup  := layeredImage32.InsertNewLayer(TLineLayer32,
      clickedLayer.Index +1, 'line');
    TLineLayer32(dup).SetSmoothPathAndDraw(TLineLayer32(clickedLayer).SmoothPath);
  end;

  dup.Offset(20,20);
  clickedLayer := dup;
  UpdateLayeredImage;
  UpdateMenus;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuDeleteLayerClick(Sender: TObject);
begin
  if Assigned(clickedLayer) and
    ((clickedLayer is TSmoothPathLayer32) or (clickedLayer is TTextLayer32)) then
  begin
    layeredImage32.DeleteLayer(clickedLayer.Index);
    clickedLayer := nil;
    UpdateLayeredImage;
  end;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.CopytoClipboard1Click(Sender: TObject);
begin
  layeredImage32.GetMergedImage(true).CopyToClipBoard;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuShowGridClick(Sender: TObject);
begin
  if (Sender <> mnuShowDesigner) and not mnuShowDesigner.Checked then Exit;
  mnuShowGrid.OnClick := nil;
  mnuShowHatchedBackground.OnClick := nil;
  mnuShowDesigner.OnClick := nil;
  try
    TMenuItem(Sender).Checked := not TMenuItem(Sender).Checked;
    with TDesignerLayer32(layeredImage32[0]) do
    begin
      if Sender = mnuShowDesigner then
      begin
        mnuShowGrid.Checked := false;
        mnuShowHatchedBackground.Checked := mnuShowDesigner.Checked;
      end;

      if not TMenuItem(Sender).Checked then
      begin
        Image.Clear;
      end else if (Sender = mnuShowGrid) then
      begin
        Image.Clear(clWhite32);
        DrawGrid(0,20);
        mnuShowHatchedBackground.Checked := false;
      end else
      begin
        Image.Clear;
        HatchBackground(Image);
        mnuShowGrid.Checked := false;
      end;
    end;
  finally
    mnuShowGrid.OnClick := mnuShowGridClick;
    mnuShowHatchedBackground.OnClick := mnuShowGridClick;
    mnuShowDesigner.OnClick := mnuShowGridClick;
  end;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.edPenColorChange(Sender: TObject);
var
  rec: TRect;
  c: TColor;
begin
  UpdateLayeredImage;
  if Length(FrmMain.edPenColor.Text) = 9 then
    penColor := TColor32(StrToInt64Def(FrmMain.edPenColor.Text, penColor));

  if Length(FrmMain.edFillColor.Text) = 9 then
    fillColor := TColor32(StrToInt64Def(FrmMain.edFillColor.Text, fillColor));

  //color pnlTop behind edPenColor and edFillColor edit windows with fillColor
  c := RGBColor(BlendToOpaque(Color32(clBtnFace), fillColor));
  pnlTop.Bitmap.Canvas.Brush.Color := c;
  rec := Rect(lblFillColor.Left -5,
    edFillColor.Top - 5,
    edPenColor.Left + edPenColor.Width +5,
    edPenColor.Top + edPenColor.Height + 5);
  pnlTop.Bitmap.Canvas.FillRect(rec);
  pnlTop.Bitmap.Canvas.Brush.Color := clBtnFace;

  //change the color label font colors to the chosen pen color
  c := RGBColor(penColor);
  lblFillColor.Font.Color := c;
  lblPenColor.Font.Color := c;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.edWidthChange(Sender: TObject);
begin
  lineWidth := Max(1, Min(25, strtoint(edWidth.text)));
  //only repaint after starting up
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuTypeChangeClick(Sender: TObject);
var
  newType, oldType: TSmoothType;
begin
   //changing vertex point type
  if disableTypeChangeClick then Exit;
  if not assigned(clickedLayer) or rbPolygonArrow.Checked or
    (clickedLayer.GroupId <> 1) then Exit;

  oldType := TExButtonDesignerLayer32(clickedLayer).PointType;
  if Sender = mnuSmoothSym then newType := stSmoothSym
  else if Sender = mnuSmoothAsym then newType := stSmoothAsym
  else if Sender = mnuSharpWithHdls then newType := stSharpWithHdls
  else newType := stSharpNoHdls;
  if newType = oldType then Exit;

  buttonPath.PointTypes[clickedLayer.IndexInGroup] := newType;
  //buttonPath shape may change with new point type
  UpdateButtonGroupFromPath;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.UpdateMenus;
var
  nodeTypeEnabled: Boolean;
begin
  mnuEndEdit.Enabled :=
    (buttonPath.Count > 0) and buttonPath.CurrentCurveIsComplete;
  mnuFinishEdit2.Enabled := mnuEndEdit.Enabled;
  mnuEditLayer.Enabled :=
    Assigned(clickedLayer) and (clickedLayer is TSmoothPathLayer32);
  mnuEditLayer2.Enabled := mnuEditLayer.Enabled;

  mnuDeleteLayer.Enabled :=
    Assigned(clickedLayer) and
    ((clickedLayer is TSmoothPathLayer32) or (clickedLayer is TTextLayer32));
  mnuDeleteLayer2.Enabled := mnuDeleteLayer.Enabled;
  mnuDuplicateLayer.Enabled := mnuDeleteLayer.Enabled;
  mnuDuplicateLayer2.Enabled := mnuDeleteLayer.Enabled;

  mnuRotateButtons.Enabled := buttonPath.Count > 1;
  mnuRotateButtons2.Enabled := mnuRotateButtons.Enabled;
  mnuScaleButtons.Enabled := buttonPath.Count > 1;
  mnuScaleButtons2.Enabled := mnuScaleButtons.Enabled;
  mnuDeleteButton.Enabled :=
    (buttonPath.Count > 0) and not rbPolygonArrow.Checked;
  mnuDeleteAllButtonControls.Enabled := (buttonPath.Count > 0);

  nodeTypeEnabled := Assigned(clickedLayer) and rbLineArrow.Checked and
    (clickedLayer.GroupId = 1) and (clickedLayer.IndexInGroup mod 3 = 0);
  mnuSmoothSym.Enabled := nodeTypeEnabled;
  mnuSmoothAsym.Enabled := nodeTypeEnabled;
  mnuSharpWithHdls.Enabled := nodeTypeEnabled;
  mnuSharpNoHdls.Enabled := nodeTypeEnabled;
  if nodeTypeEnabled then
  begin
    disableTypeChangeClick := true;
    try
      if Assigned(clickedLayer) then
        case TExButtonDesignerLayer32(clickedLayer).PointType of
          stSmoothSym: mnuSmoothSym.Checked := true;
          stSmoothAsym: mnuSmoothAsym.Checked := true;
          stSharpWithHdls: mnuSharpWithHdls.Checked := true;
          stSharpNoHdls: mnuSharpNoHdls.Checked := true;
        end
      else mnuSmoothSym.Checked := true;
    finally
      disableTypeChangeClick := false;
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.DisplayFont;
var
  fontWeightStr: string;
  textWidth: double;
begin
  if DefaultLogfont.lfWeight >= 700 then
    fontWeightStr := '; Bold' else
    fontWeightStr := '';

  pnlText.Caption := DefaultLogfont.lfFaceName + fontWeightStr +
    '; ' + Inttostr(GetFontSize(DefaultLogfont));
  textWidth := GetFontInfo(DefaultLogfont).MeasureText(pnlText.Caption).X;
  if textWidth > pnlText.ClientWidth then
    pnlText.Caption := DefaultLogfont.lfFaceName;
  pnlText.Font.Handle := GetFontInfo(DefaultLogfont).Handle;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuFontClick(Sender: TObject);
begin
  FontDialog1.Font.Handle := GetFontInfo(DefaultLogfont).Handle;
  if not FontDialog1.Execute then Exit;
  GetObject(FontDialog1.Font.Handle, SizeOf(TLogFont), @DefaultLogfont);
  DisplayFont;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.rbLineArrowClick(Sender: TObject);
begin
  ClearRotateSizeButton;
  buttonPath.Clear;
  btnPathRegion := nil;
  if Sender = rbPolygonArrow then
    StartPolygonArrow else
    UpdateButtonGroupFromPath;
  UpdateLayeredImage;
  cbArrowStart.Enabled := Sender = rbLineArrow;
  cbArrowEnd.Enabled := cbArrowStart.Enabled;
  lblArrowStart.Enabled := cbArrowStart.Enabled;
  lblArrowEnd.Enabled := cbArrowStart.Enabled;
end;
//------------------------------------------------------------------------------

function TFrmMain.ClearRotateSizeButton: Boolean;
begin
  Result := layeredImage32.GroupCount(2) > 0;
  if Result then layeredImage32.DeleteGroup(2);
end;
//------------------------------------------------------------------------------

procedure TFrmMain.StartPolygonArrow;
var
  i: integer;
  defaultArrowPts: TArrayOfPointD;
begin
  defaultArrowPts :=
//    MakePathI([200,200, 250,150, 250,175,
//      300,175, 300,225, 250,225, 250,250]);
    MakePathI([200,200, 300,100, 300,150,
      400,150, 400,250, 300,250, 300,300]);
  buttonPath.Clear;
  buttonPath.Add(defaultArrowPts[0], stSharpNoHdls);
  for i := 1 to high(defaultArrowPts) do
    buttonPath.Add(defaultArrowPts[i]);
  UpdateButtonGroupFromPath;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.PopupMenu1Popup(Sender: TObject);
begin
  GetCursorPos(popupPos);
  popupPos := pnlMain.ScreenToClient(popupPos);
  pnlMain.ClientToBitmap(popupPos);
end;
//------------------------------------------------------------------------------

procedure TFrmMain.AddText1Click(Sender: TObject);
var
  textLayer: TLayer32;
  text: string;
begin
  //just in case the rotation/scaling button is active ...
  ClearRotateSizeButton;
  if not PtInRect(pnlMain.InnerClientRect, popupPos) then Exit;

  text := InputBox(Self.Caption, 'Enter Text:', '');
  if text = '' then Exit;

  textLayer  := layeredImage32.InsertNewLayer(TTextLayer32,
    designLayer.Index, text);
  TTextLayer32(textLayer).PositionTextAndDraw(popupPos);

  clickedLayer := textLayer;
  UpdateLayeredImage;
  UpdateMenus;
  popupPos := Types.Point(0,0); //reset
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuLoadImageClick(Sender: TObject);
var
  i: integer;
  resized: Boolean;
begin
  if not OpenDialog1.Execute then Exit;
  layeredImage32[1].Image.LoadFromFile(OpenDialog1.FileName);
  resized := false;
  if layeredImage32.Width < layeredImage32[1].Image.Width then
  begin
    layeredImage32.Width := layeredImage32[1].Image.Width;
    resized := true;
  end;
  if layeredImage32.Height < layeredImage32[1].Image.Height then
  begin
    layeredImage32.Height := layeredImage32[1].Image.Height;
    resized := true;
  end;
  if resized then
    with layeredImage32 do
    begin
      layeredImage32[0].SetSize(Width, Height);
      HatchBackground(layeredImage32[0].Image);

      i := 2;
      while layeredImage32[i].Name <> 'designer' do inc(i);
      layeredImage32[i].SetSize(Width, Height);
    end;
  layeredImage32[1].Visible := true;
  UpdateLayeredImage;
  UpdateMenus;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.mnuRemoveImageClick(Sender: TObject);
begin
  if layeredImage32[1].Image.IsEmpty then Exit;
  layeredImage32[1].Image.Clear;
  layeredImage32[1].Visible := false;
  UpdateLayeredImage;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.SavetoFile1Click(Sender: TObject);
begin
  if not SaveDialog1.Execute then Exit;
  layeredImage32.GetMergedImage(true).SaveToFile(SaveDialog1.FileName);
  StatusBar1.SimpleText := ' File saved.';
end;
//------------------------------------------------------------------------------

procedure TFrmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;
//------------------------------------------------------------------------------

procedure TFrmMain.PanelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i, dist, dx, dy: integer;
  angle: double;
  pt: TPointD;
begin
  case Key of
    VK_ESCAPE:
      begin
        clickedLayer := nil;
        ClearRotateSizeButton;
      end;
    VK_TAB:
      begin
        if not (ssCtrl in Shift) then Exit;
        if Assigned(clickedLayer) then i := clickedLayer.Index +1
        else i := 0;
        while (i < layeredImage32.Count) and
          (not layeredImage32[i].Visible or
          (layeredImage32[i] is TDesignerLayer32)) do inc(i);
        if (i = layeredImage32.Count) then
        begin
          if not Assigned(clickedLayer) then Exit;
          i := 0;
          while (i < clickedLayer.Index) and
            (not layeredImage32[i].Visible or
            (layeredImage32[i] is TDesignerLayer32)) do inc(i);
        end;
        clickedLayer := layeredImage32[i];
      end;
    VK_LEFT .. VK_DOWN:
      begin
        if (clickedLayer = nil) then Exit;
        if ssCtrl in Shift then dist := 10 else dist := 1;
        if clickedLayer is TButtonDesignerLayer32 then
        begin
          pt := clickedLayer.MidPoint;
          clickPoint := Point(pt);
          case Key of
            VK_LEFT: pt.X := pt.X - dist;
            VK_RIGHT: pt.X := pt.X + dist;
            VK_UP: pt.Y := pt.Y - dist;
            VK_DOWN: pt.Y := pt.Y + dist;
          end;
          if clickedLayer.GroupId = 2 then
          begin
            dx := 0; dy := 0;
            case Key of
              VK_LEFT: dx := -dist;
              VK_RIGHT: dx := dist;
              VK_UP: dy := -dist;
              VK_DOWN: dy := dist;
            end;
            if clickedLayer.Name = 'Rotate' then
            begin
              clickedLayer.Offset(dx, dy);
              angle := GetAngle(clickPoint, rotPoint, Point(pt));
              buttonPath.Rotate(PointD(rotPoint), angle);
              RefreshButtonPositionsFromPath;
            end
            else Exit;
          end else
          begin
            if rbPolygonArrow.Checked then
              AdjustArrow(clickedLayer.IndexInGroup div 3, pt) else
              buttonPath[clickedLayer.IndexInGroup] := pt;
          end;
          RefreshButtonPositionsFromPath;
        end else
        begin
           case Key of
            VK_LEFT: clickedLayer.Offset(-dist, 0);
            VK_RIGHT: clickedLayer.Offset(dist, 0);
            VK_UP: clickedLayer.Offset(0, -dist);
            VK_DOWN: clickedLayer.Offset(0, dist);
          end;
        end;
      end;
    else
      Exit;
  end;
  UpdateLayeredImage;
  UpdateMenus;
  Key := 0;
end;
//------------------------------------------------------------------------------

end.