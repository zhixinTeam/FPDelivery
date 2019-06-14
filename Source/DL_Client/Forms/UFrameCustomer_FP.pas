unit UFrameCustomer_FP;
{$I Link.Inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ExtCtrls, ADODB,
  cxLabel, UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, dxLayoutcxEditAdapters,
  cxMaskEdit, cxButtonEdit, cxTextEdit, cxTreeView, cxTL,
  cxInplaceContainer, Menus, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter;

type
  TfFrameCustomer_FP = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTreeList1: TcxTreeList;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N5: TMenuItem;
    m_bindWechartAccount: TMenuItem;
    N6: TMenuItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxTreeList1Click(Sender: TObject);
    procedure cxTreeList1DblClick(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure m_bindWechartAccountClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
  private
    FListA: TStrings;
    { Private declarations }
  protected
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    function AddMallUser(const nBindcustomerid,nCus_num,nCus_name:string):Boolean;
    function DelMallUser(const nNamepinyin,nCus_id:string):boolean;
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure createTreeView;
    procedure GetFieldAndTitle;
    function CreateTreeNode(ParentId: string; Mynode: TcxTreeListNode): Boolean;
  end;

var
  fFrameCustomer_FP: TfFrameCustomer_FP;
  TVFields: array of string;
  ChannelCount, myFieldCount: integer;
  CusList,ParentList: TStringList;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, ULibFun, USysDB, UDataModule, UFormBase, UFormInputbox,
  UBusinessPacker, USysBusiness, USysLoger, uFormGetWechartAccount;

//创建节点
function TfFrameCustomer_FP.CreateTreeNode(ParentId: string;
  Mynode: TcxTreeListNode): Boolean;
var
   i,n: integer;
   ChildNode: TcxTreeListNode;
   nStr: string;
begin
  cxTreeList1.BeginUpdate;
  for i := 0 to ChannelCount - 1 do
  if UpperCase(ParentList[i]) = UpperCase(ParentId) then // 第一次调用 ParentId=0
  begin
    ChildNode := cxTreeList1.AddChild(Mynode);
    childnode.ImageIndex := 8;
    childnode.SelectedIndex := 10;

    nStr := 'Select cus.*,S_Name From $Cus cus' +
            ' Left Join $Sale On S_ID=cus.C_SaleMan Where c_id=''$s'' and C_XuNi<>''$Yes''';

    nStr := MacroValue(nStr, [MI('$Cus', sTable_Customer),
            MI('$Sale', sTable_Salesman), MI('$s', CusList[i]), MI('$Yes', sFlag_Yes)]);

    with FDM.QueryTemp(nStr) do
    begin
      if recordcount = 0 then exit;
      ChildNode.Texts[0] := FieldByName('c_id').asstring +'-'+FieldByName('C_Name').asstring ;
      for n := 1 to myFieldCount -1  do
      begin
        ChildNode.Texts[n] := FieldByName(tvfields[n]).asstring;
      end;
    end;
    CreateTreeNode(CusList[i], ChildNode); // 递归
    ChildNode.Expanded := true;
  end;
  cxTreeList1.EndUpdate;
//  ParentList.Free;
//  CusList.Free;
end;

procedure TfFrameCustomer_FP.createTreeView;
var
  i: integer;
  nStr: string;
begin
  CusList := TStringList.Create;
  ParentList := TStringList.Create;
  with SQLQuery do  
  begin
    if recordcount = 0 then exit;
    ChannelCount:=recordcount;      //数据行数
    First;
    for i:=0 to channelcount-1 do   //用数组存储表中记录
    begin
      CusList.Add(FieldByName('c_id').Asstring);
      ParentList.Add(FieldByName('c_parent').Asstring);
      Next;
    end;
  end;
  CreateTreeNode('',nil);  // 开始递归生成树
  SQLQuery.First;
end;

class function TfFrameCustomer_FP.FrameID: integer;
begin
  Result := cFI_FrameCustomer_FP;
end;

procedure TfFrameCustomer_FP.GetFieldAndTitle;
var
  nStr :string;
  i : integer;
begin
  nStr := 'select D_Title,D_DBField,D_Width from %s where D_Entity=''ZXSOFT_MAIN_B02'' order by D_Index';
  nStr := Format(nStr,[sTable_DictItem]);
  with FDM.QueryTemp(nStr) do
  begin
    myFieldCount := recordcount;
    SetLength(TVFields,myFieldCount);
    First;
    for I := 0 to myFieldCount-1 do
    begin
      TVFields[i]:= fieldbyname('D_DBField').AsString;
      with cxTreeList1.CreateColumn(nil) do
      begin
        Visible := true;
        //Options.Moving := False;
        if i = 0 then
          Width := 200
        else
          width := fieldbyname('D_Width').AsInteger;
        Caption.Text := fieldbyname('D_Title').AsString;
        Caption.AlignHorz := taCenter;
      end;
      next;
    end;
  end;
end;

procedure TfFrameCustomer_FP.OnCreateFrame;
begin
  inherited;
  GetFieldAndTitle;
  FListA := TStringList.Create;
end;

procedure TfFrameCustomer_FP.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameCustomer_FP.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

procedure TfFrameCustomer_FP.BtnDelClick(Sender: TObject);
var nStr,nSQL,nReson: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;
  nStr := SQLQuery.FieldByName('C_ID').AsString;

  nSQL := 'select count(*) from %s where C_Parent=''%s''';
  nSQL := Format(nSQL, [sTable_Customer, nStr]);
  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('该客户不能删除', '存在下级客户');
    Exit;
  end;

  nSQL := 'Select Count(*) From %s Where Z_Customer=''%s''';
  nSQL := Format(nSQL, [sTable_ZhiKa, nStr]);
  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('该客户不能删除', '已办订单');
    Exit;
  end;

  nStr := SQLQuery.FieldByName('C_Name').AsString;
  if not QueryDlg('确定要删除名称为[ ' + nStr + ' ]的客户吗', sAsk) then Exit;

  if not ShowInputBox('请输入删除原因:', sHint, nReson) then Exit;
  if nReson = '' then
  begin
    ShowDlg('删除原因不能为空.',sHint);
    Exit;
  end;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('C_ID').AsString;
    nSQL := 'Delete From %s Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Customer, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
    nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_CustomerItem, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where A_CID=''%s''';
    nSQL := Format(nSQL, [sTable_CusAccount, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where C_CusID=''%s''';
    nSQL := Format(nSQL, [sTable_CusCredit, nStr]);
    FDM.ExecuteSQL(nSQL);

    FDM.WriteSysLog(sFlag_ZhiKaItem, nStr, '删除客户:[ '+ nStr+ ' - ' +
          SQLQuery.FieldByName('C_Name').AsString +' ], 原因:' + nReson);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('已成功删除记录', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除记录失败', '未知错误');
  end;
end;

function TfFrameCustomer_FP.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select cus.*,S_Name From $Cus cus' +
            ' Left Join $Sale On S_ID=cus.C_SaleMan';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where C_XuNi<>''$Yes'''
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$Cus', sTable_Customer),
            MI('$Sale', sTable_Salesman), MI('$Yes', sFlag_Yes)]);
end;

procedure TfFrameCustomer_FP.AfterInitFormData;
begin
  inherited;
  cxTreeList1.Clear;
  createTreeView;
end;

procedure TfFrameCustomer_FP.cxTreeList1Click(Sender: TObject);
var
  ClkNode: TcxTreeListNode;
  nStr: string;
  i: integer;
begin
  if cxTreeList1.Nodes.Count = 0 then Exit;
  ClkNode := cxTreeList1.FocusedNode;
  nstr := ClkNode.Texts[0];
  i := Pos('-',nStr)-1;
  nStr := Copy(nStr,0,i);
  SQLQuery.Locate('C_ID',nStr,[loCaseInsensitive]);
end;

procedure TfFrameCustomer_FP.cxTreeList1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
    CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);
  end;
end;

procedure TfFrameCustomer_FP.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'C_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameCustomer_FP.N1Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('IsNull(C_XuNi, '''')=''%s''', [sFlag_Yes]);
    20: FWhere := '1=1';
  end;

  InitFormData(FWhere);

end;

procedure TfFrameCustomer_FP.m_bindWechartAccountClick(Sender: TObject);
var
  nP: TFormCommandParam;
  nCus_ID,nCusName:string;
  nBindcustomerid:string;
  nWechartAccount:string;
  nStr, nMsg:string;
  nID,nName,nBindID,nAccount,nPhone:string;
  nFListA : TStrings;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要开通的记录', sHint);
    Exit;
  end;

  nAccount := Trim(SQLQuery.FieldByName('C_WeiXin').AsString);
  if nAccount <> '' then
  begin
    ShowMsg('商城账户[' + nAccount + ']已存在',sHint);
    Exit;
  end;

  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormGetWXAccount, PopedomItem, @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  nBindID  := nP.FParamB;
  nAccount := nP.FParamC;
  nPhone   := nP.FParamD;
  nID      := SQLQuery.FieldByName('C_ID').AsString;
  nName    := SQLQuery.FieldByName('C_Name').AsString;

  with FListA do
  begin
    Clear;
    Values['Action']   := 'add';
    Values['BindID']   := nBindID;
    Values['Account']  := nAccount;
    Values['CusID']    := nID;
    Values['CusName']  := nName;
    Values['Memo']     := sFlag_Sale;
    Values['Phone']    := nPhone;
    Values['btype']    := '1';
  end;
  nMsg := edit_shopclients(PackerEncodeStr(FListA.Text));
  if nMsg <> sFlag_Yes then
  begin
     ShowMsg('关联商城账户失败：'+nMsg,sHint);
     Exit;
  end;
  //call remote

  nStr := 'update %s set C_WeiXin=''%s'',C_Phone=''%s'',C_custSerilaNo=''%s'' where C_ID=''%s''';
  nStr := Format(nStr,[sTable_Customer, nAccount, nPhone, nBindID, nID]);
  FDM.ExecuteSQL(nStr);

  ShowMsg('关联商城账户成功',sHint);
  InitFormData(FWhere);
  {nWechartAccount := SQLQuery.FieldByName('C_WechartAccount').AsString;
  if nWechartAccount<>'' then
  begin
    ShowMsg('商城账户['+nWechartAccount+']已存在',sHint);
    Exit;
  end;

  nFListA := TStringList.Create;

  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormGetWechartAccount, PopedomItem, @nParam);

  if (nParam.FCommand <> cCmd_ModalResult) or (nParam.FParamA <> mrOK) then Exit;

  nBindID  := nParam.FParamB;
  nAccount := nParam.FParamC;
  nID      := SQLQuery.FieldByName('C_ID').AsString;
  nName    := SQLQuery.FieldByName('C_Name').AsString;

  with nFListA do
  begin
    Clear;
    Values['Action']   := 'add';
    Values['BindID']   := nBindID;
    Values['Account']  := nAccount;
    Values['CusID']    := nID;
    Values['CusName']  := nName;
    Values['Memo']     := sFlag_Sale;
  end;

  if edit_shopclients(PackerEncodeStr(nFListA.Text)) <> sFlag_Yes then Exit;
  //call remote

   nStr := 'update %s set C_WechartAccount=''%s'' where C_ID=''%s''';
  nStr := Format(nStr,[sTable_Customer, nAccount, nID]);
  FDM.ExecuteSQL(nStr);

  ShowMsg('关联商城账户成功',sHint);
  InitFormData(FWhere);
  nFListA.Free;}
end;

procedure TfFrameCustomer_FP.N6Click(Sender: TObject);
var
  nWechartAccount:string;
  nStr:string;
  nCus_ID, nCusName:string;
  nID,nName, nAccount, nPhone, nBindID, nMsg:string;
  nFListA: TStrings;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要取消的记录', sHint);
    Exit;
  end;
  nWechartAccount := SQLQuery.FieldByName('C_WeiXin').AsString;
  if nWechartAccount='' then
  begin
    ShowMsg('商城账户不已存在',sHint);
    Exit;
  end;

  nAccount := SQLQuery.FieldByName('C_WeiXin').AsString;
  nID := SQLQuery.FieldByName('C_ID').AsString;
  nName := SQLQuery.FieldByName('C_Name').AsString;

  nPhone   := SQLQuery.FieldByName('C_Phone').AsString;
  nBindID  := SQLQuery.FieldByName('C_custSerilaNo').AsString;

  with FListA do
  begin
    Clear;
    Values['Action']   := 'del';
    Values['Account']  := nAccount;
    Values['CusID']    := nID;
    Values['CusName']  := nName;
    Values['Memo']     := sFlag_Sale;
    Values['Phone']    := nPhone;
    Values['BindID']   := nBindID;
    Values['btype']    := '1';
  end;
  nMsg := edit_shopclients(PackerEncodeStr(FListA.Text));
  if nMsg <> sFlag_Yes then
  begin
     ShowMsg('取消关联商城账户失败：'+nMsg,sHint);
     Exit;
  end;
  //call remote

  nStr := 'update %s set C_WeiXin=Null,C_Phone=Null, C_custSerilaNo= Null where C_ID=''%s''';
  nStr := Format(nStr,[sTable_Customer, nID]);
  FDM.ExecuteSQL(nStr);

  ShowMsg('取消商城关联成功！', sHint);
  {nFListA := TStringList.Create;
  with nFListA do
  begin
    Clear;
    Values['Action']   := 'del';
    Values['Account']  := nAccount;
    Values['CusID']    := nID;
    Values['CusName']  := nName;
    Values['Memo']     := sFlag_Sale;
  end;

  if edit_shopclients(PackerEncodeStr(nFListA.Text)) <> sFlag_Yes then Exit;
  //call remote
  nFListA.Free;

  nStr := 'update %s set C_WechartAccount=Null where C_ID=''%s''';
  nStr := Format(nStr,[sTable_Customer, nID]);
  FDM.ExecuteSQL(nStr);

  InitFormData(FWhere);
  ShowMsg('取消商城关联成功！', sHint);}
end;

function TfFrameCustomer_FP.AddMallUser(const nBindcustomerid, nCus_num,
  nCus_name: string): Boolean;
var
  nXmlStr:string;
  nData:string;
  ntype:string;
begin
  Result := False;
  ntype := 'add';
  //发送绑定请求开户请求
  nXmlStr := '<?xml version="1.0" encoding="UTF-8" ?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<Customer>%s</Customer>'
            +'<Provider />'
            +'<type>%s</type>'
            +'</head>'
            +'<Items>'
            +'<Item>'
            +'<clientname>%s</clientname>'
            +'<cash>0</cash>'
            +'<clientnumber>%s</clientnumber>'
            +'</Item>'
            +'</Items>'
            +'<remark />'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nBindcustomerid,ntype,nCus_name,nCus_num]);
  nXmlStr := PackerEncodeStr(nXmlStr);

  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameCustomer_FP,'AddMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('客户[ '+nCus_num+' ]关联商城账户失败！', sError);
    Exit;
  end;
  Result := True;
end;

function TfFrameCustomer_FP.DelMallUser(const nNamepinyin,
  nCus_id: string): boolean;
var
  nXmlStr:string;
  nData:string;
begin
  Result := False;
  //发送http请求
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head>'
      +'<Factory>%s</Factory>'
      +'<Customer>%s</Customer>'
      +'<type>del</type>'
      +'</head>'
      +'<Items>'
      +'<Item>'
      +'<clientnumber>%s</clientnumber>'
      +'</Item></Items><remark/></DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nNamepinyin,nCus_id]);
  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameCustomer_FP,'DelMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('客户[ '+nCus_id+' ]取消商城账户关联 失败！', sError);
    Exit;
  end;
  Result := True;
end;

procedure TfFrameCustomer_FP.OnDestroyFrame;
begin
  FListA.Free;
  inherited;
end;

initialization
  gControlManager.RegCtrl(TfFrameCustomer_FP, TfFrameCustomer_FP.FrameID);

end.
