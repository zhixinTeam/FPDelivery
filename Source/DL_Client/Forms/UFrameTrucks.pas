{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 车辆档案管理
*******************************************************************************}
unit UFrameTrucks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, dxLayoutControl, cxMaskEdit, cxButtonEdit, cxTextEdit,
  ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus,
  dxLayoutcxEditAdapters, dxSkinscxPCPainter;

type
  TfFrameTrucks = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    VIP1: TMenuItem;
    VIP2: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure VIP1Click(Sender: TObject);
    procedure VIP2Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysBusiness, USysConst, USysDB, UDataModule, UFormBase,
  UFormTruckCard, UBusinessPacker,UFormInputbox;

class function TfFrameTrucks.FrameID: integer;
begin
  Result := cFI_FrameTrucks;
end;

function TfFrameTrucks.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'select a.*,b.S_CarModel,S_Value from S_Truck a left join Sys_LoadStandard b on t_loadstand=b.S_No ' ;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By T_PY';
end;

//Desc: 添加
procedure TfFrameTrucks.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormTrucks, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameTrucks.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_Id').AsString;
    CreateBaseFormItem(cFI_FormTrucks, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameTrucks.BtnDelClick(Sender: TObject);
var nStr,nTruck,nEvent,nReson: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nTruck := SQLQuery.FieldByName('T_Truck').AsString;
    nStr   := Format('确定要删除车辆[ %s ]吗?', [nTruck]);
    if not QueryDlg(nStr, sAsk) then Exit;

    if not ShowInputBox('请输入删除原因:', sHint, nReson) then Exit;
    if nReson = '' then
    begin
      ShowDlg('删除原因不能为空.',sHint);
      Exit;
    end;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, SQLQuery.FieldByName('R_Id').AsString]);

    FDM.ExecuteSQL(nStr);

    nEvent := '删除[ %s ]档案信息, 原因：'+nReson;
    nEvent := Format(nEvent, [nTruck]);
    FDM.WriteSysLog(sFlag_CommonItem, nTruck, nEvent);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameTrucks.PMenu1Popup(Sender: TObject);
begin
  N2.Enabled := BtnEdit.Enabled;
end;

//Desc: 车辆签到
procedure TfFrameTrucks.N2Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_LastTime=getDate() Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('签到成功', sHint);
  end;
end;

//Desc: 查询
procedure TfFrameTrucks.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('T_Truck Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//办理电子标签
procedure TfFrameTrucks.N4Click(Sender: TObject);
var nStr, nRFIDCard, nFlag: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('T_Truck').AsString;
    nRFIDCard := SQLQuery.FieldByName('T_Card').AsString;
    nFlag := SQLQuery.FieldByName('T_CardUse').AsString;
    
    if SetTruckRFIDCard(nStr, nRFIDCard, nFlag, nRFIDCard) then
    begin
      nStr := 'Update %s Set T_Card=null,T_CardUse=''%s''  Where T_Card=''%s''';
      nStr := Format(nStr, [sTable_Truck, {nRFIDCard,} nFlag,
        nRFIDCard]);
      //xxxxxx

      FDM.ExecuteSQL(nStr);//将已经绑定该标签的电子签清除

      nStr := 'Update %s Set T_Card=''%s'',T_CardUse=''%s''  Where R_ID=%s';
      nStr := Format(nStr, [sTable_Truck, nRFIDCard, nFlag,
        SQLQuery.FieldByName('R_ID').AsString]);
      //xxxxxx

      FDM.ExecuteSQL(nStr);
      InitFormData(FWhere);
      ShowMsg('办理电子标签成功', sHint);
    end;
  end;
end;


//启用电子标签
procedure TfFrameTrucks.N5Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_CardUse=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_Yes,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('启用电子标签成功', sHint);
  end;
end;

procedure TfFrameTrucks.N7Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_CardUse=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_No,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('停用电子标签成功', sHint);
  end;
end;

procedure TfFrameTrucks.VIP1Click(Sender: TObject);
var nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_VIPTruck=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_TypeVIP,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('设置车辆VIP成功', sHint);
  end;
end;

procedure TfFrameTrucks.VIP2Click(Sender: TObject);
var nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_VIPTruck=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_TypeCommon,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('关闭车辆VIP成功', sHint);
  end;
end;

procedure TfFrameTrucks.N8Click(Sender: TObject);
var
  nP: TFormCommandParam;
  nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := Trim(SQLQuery.FieldByName('T_Card').AsString);
    if nStr <> '' then
    begin
      ShowMsg('该车已经绑定过磁卡,请勿重复绑定.',sHint);
      Exit;
    end;
    
    //nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('T_Truck').AsString;
    CreateBaseFormItem(cFI_FormTruckCard, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then       
    begin
      InitFormData(FWhere);
    end;
  end;
end;

procedure TfFrameTrucks.N9Click(Sender: TObject);
var
  nStr, nSQL, nTruck, nWebId: string;
  nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nTruck := Trim(SQLQuery.FieldByName('T_Truck').AsString);
    nStr := Trim(SQLQuery.FieldByName('T_Card').AsString);
    nWebId := Trim(SQLQuery.FieldByName('T_WebId').AsString);

    if nStr = '' then exit;
    if not QueryDlg('确定要取消车辆 ['+nTruck+'] 的关联的长期卡吗？', sAsk) then Exit;

    try
      FDM.ADOConn.BeginTrans;

      nSQL := 'update %s set t_card=''%s'' where t_truck=''%s''';
      nSQL := Format(nSQL,[sTable_Truck,'',nTruck]);
      FDM.ExecuteSQL(nSQL);

      //同步状态到商城
      nList := TStringList.Create;
      with nList do
      begin
        Clear;
        Values['ID']   := nWebId;
        Values['Status']  := '1';
        Values['Memo']    := '';
        Values['Man']  := gSysParam.FUserID;
        Values['Type']     := '0';
      end;
      {if UpLoadAuditTruck(PackerEncodeStr(nList.Text)) <> sFlag_Yes then
      begin
        FDM.ADOConn.RollbackTrans;
        Exit;
      end;}
      //call remote 同步到微信端

      FDM.ADOConn.CommitTrans;

      nStr := '取消车辆 [ '+ nTruck +' ]与磁卡[ '+nStr+' ]的关联';
      FDM.WriteSysLog(sFlag_TruckItem,nTruck,nStr);
      ShowMsg(nStr, sHint);

      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('取消关联失败.', sHint);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameTrucks, TfFrameTrucks.FrameID);
end.
