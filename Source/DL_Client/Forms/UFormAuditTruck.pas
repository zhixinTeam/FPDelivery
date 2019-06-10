{*******************************************************************************
  作者: dmzn 2008-9-20
  描述: 公司信息
*******************************************************************************}
unit UFormAuditTruck;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxContainer, cxEdit,
  cxTextEdit, cxControls, cxMemo, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxImage, jpeg, DB, cxMaskEdit, cxDropDownEdit,
  dxLayoutcxEditAdapters, UFormCtrl, dxSkinsCore, dxSkinsDefaultPainters;

type
  TfFormAuditTruck = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditType: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayoutControl1Item6: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item7: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    ImageTruck: TcxImage;
    dxLayoutControl1Item9: TdxLayoutItem;
    EditResult: TcxComboBox;
    dxLayoutControl1Item3: TdxLayoutItem;
    editTypeName: TcxTextEdit;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    editSB: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    editHZ: TcxTextEdit;
    dxLayoutControl1Item10: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    dxLayoutControl1Group5: TdxLayoutGroup;
    dxLayoutControl1Group6: TdxLayoutGroup;
    dxLayoutControl1Group7: TdxLayoutGroup;
    eeditPhone: TcxTextEdit;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group8: TdxLayoutGroup;
    lblwebid: TLabel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FTruckID: string;
    //车辆标识
    procedure InitFormData;
    {*初始化界面*}
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysConst, USysDB, USysPopedom, UFormWait,
  USysBusiness, UBusinessPacker;

//------------------------------------------------------------------------------
class function TfFormAuditTruck.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormAuditTruck.Create(Application) do
  begin
    nP.FCommand := cCmd_ModalResult;
    FTruckID := nP.FParamA;
    case nP.FParamB of
      6:
      begin
        EditResult.ItemIndex := 1;
        EditResult.Enabled := False;
      end;
      7:
      begin
        EditResult.ItemIndex := 0;
        EditResult.Enabled := False;
      end;
    end;
    InitFormData;
    BtnOK.Enabled := gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);

    ShowModal;
    Free;
  end;
end;

class function TfFormAuditTruck.FormID: integer;
begin
  Result := cFI_FormAuditTruck;
end;

//Desc: 初始化界面数据
procedure TfFormAuditTruck.InitFormData;
var nStr: string;
    nPic: TPicture;
    nStream: TMemoryStream;
    nField: TField;
    nJpg: TjpegImage;
begin
  ShowWaitForm(Self, '下载图片', True);
  try
    if DownLoadPic(PackerEncodeStr(FTruckID)) <> sFlag_Yes then
    begin
      CloseWaitForm;
      ShowMsg('下载图片失败', sHint);
      Exit;
    end;
  except
    CloseWaitForm;
    ShowMsg('下载图片失败', sHint);
    Exit;
  end;
  nPic := nil;
  nStr := 'select * from %s ,%s where A_Serial=S_NO and A_ID=''%s''';
  nStr := Format(nStr, [sTable_AuditTruck, sTable_LoadStandard, FTruckID]);

  ShowWaitForm(Self, '加载车辆信息', True);
  try
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('加载车辆信息失败', sHint);
        Exit;
      end;

      nJpg:=TJPEGImage.Create;
      First;

      While not eof do
      begin
        EditType.Text := FieldByName('A_Serial').AsString;
        EditTruck.Text := FieldByName('A_Truck').AsString;
        EditMemo.Text := FieldByName('A_Memo').AsString;
        lblwebid.Caption := FieldByName('A_Id').AsString;  //商城唯一id
        eeditPhone.Text := FieldByName('A_phone').AsString;
        editTypeName.Text := FieldByName('S_CarModel').AsString;
        editHZ.Text := FieldByName('S_Value').AsString;
        editSB.Text := FieldByName('A_PValue').AsString;

        nStream := nil;
        try
          nField := FindField('A_License');
          if not (Assigned(nField) and (nField is TBlobField)) then
          begin
            Next;
            Continue;
          end;

          nStream := TMemoryStream.Create;
          TBlobField(nField).SaveToStream(nStream);

          nStream.Position:=0;
          nJpg.LoadFromStream(nStream);
          ImageTruck.Picture.Assign(nJpg);

          FreeAndNil(nStream);
        except
          on E : Exception do
          begin
            ShowHintMsg(E.Message,sHint);
            if Assigned(nStream) then nStream.Free;
          end;
        end;
        Next;
      end;
    end;
  finally
    if Assigned(nJpg) then nJpg.Free;
    CloseWaitForm;
    FDM.SqlTemp.Close;
  end;
end;

//Desc: 保存
procedure TfFormAuditTruck.BtnOKClick(Sender: TObject);
var nList: TStrings;
    nStr: string;
begin
  nList := TStringList.Create;

  try
    FDM.ADOConn.BeginTrans;
    with nList do
    begin
      Clear;
      Values['Truck']   := EditTruck.Text;
      Values['Status']  := IntToStr(EditResult.ItemIndex+6);
      Values['Memo']    := EditMemo.Text;
      Values['Man']  := gSysParam.FUserID;
      Values['Type']     := '-1';
    end;

    if UpLoadAuditTruck(PackerEncodeStr(nList.Text)) <> sFlag_Yes then
    begin
      FDM.ADOConn.RollbackTrans;
      Exit;
    end;
    //call remote

    nStr := 'update %s set A_Status=''%s'', A_Memo= ''%s'',' +
            ' A_Date= %s where A_ID=''%s''';
    nStr := Format(nStr,[sTable_AuditTruck, IntToStr(EditResult.ItemIndex+1),
                         EditMemo.Text, sField_SQLServer_Now, FTruckID]);
    FDM.ExecuteSQL(nStr);

    FDM.WriteSysLog(sFlag_TruckItem,EditTruck.Text,'车辆[ '+EditTruck.Text+' ]审核通过');

    //审核通过，同步进S_Truck
    if EditResult.ItemIndex = 0 then
    begin
      nStr := 'select * from %s where T_Truck=''%s''';
      nStr :=  Format(nStr,[sTable_Truck,EditTruck.Text]);
      with FDM.QueryTemp(nStr) do
      begin
        if recordcount > 0 then
        begin
          nStr := MakeSQLByStr([SF('T_LoadStand', EditType.Text),
                  SF('T_SBTare', editSB.Text),
                  SF('T_WebID', lblwebid.Caption)
                  ], sTable_Truck, SF('T_Truck', EditTruck.Text), False);
        end
        else
        begin
          nStr := MakeSQLByStr([SF('T_Truck', EditTruck.Text),
                  SF('T_LoadStand', EditType.Text),
                  SF('T_SBTare', editSB.Text),
                  SF('T_WebId', lblwebid.Caption),
                  SF('T_Phone', eeditPhone.Text),
                  SF('T_Valid', 'Y'),
                  SF('T_VipTruck', 'C')
                  ], sTable_Truck, '', True);
        end;

        FDM.ExecuteSQL(nStr);
      end;
    end;
    FDM.ADOConn.CommitTrans;
    ModalResult := mrOK;
    ShowMsg('审核结果保存成功',sHint);
    nList.Free;
  Except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('审核失败',shint);
    nList.Free;
    exit;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAuditTruck, TfFormAuditTruck.FormID);
end.
