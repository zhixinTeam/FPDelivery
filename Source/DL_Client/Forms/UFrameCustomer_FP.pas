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
  cxInplaceContainer, Menus;

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
    { Private declarations }
  protected
    procedure OnCreateFrame; override;
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
  USysConst, UMgrControl, ULibFun, USysDB, UDataModule, UFormBase,
  UBusinessPacker, USysBusiness, USysLoger, uFormGetWechartAccount;

//�����ڵ�
function TfFrameCustomer_FP.CreateTreeNode(ParentId: string;
  Mynode: TcxTreeListNode): Boolean;
var
   i,n: integer;
   ChildNode: TcxTreeListNode;
   nStr: string;
begin
  cxTreeList1.BeginUpdate;
  for i := 0 to ChannelCount - 1 do
  if UpperCase(ParentList[i]) = UpperCase(ParentId) then // ��һ�ε��� ParentId=0
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
    CreateTreeNode(CusList[i], ChildNode); // �ݹ�
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
    ChannelCount:=recordcount;      //��������
    First;
    for i:=0 to channelcount-1 do   //������洢���м�¼
    begin
      CusList.Add(FieldByName('c_id').Asstring);
      ParentList.Add(FieldByName('c_parent').Asstring);
      Next;
    end;
  end;
  CreateTreeNode('',nil);  // ��ʼ�ݹ�������
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
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
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
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;
  nStr := SQLQuery.FieldByName('C_ID').AsString;

  nSQL := 'select count(*) from %s where C_Parent=''%s''';
  nSQL := Format(nSQL, [sTable_Customer, nStr]);
  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('�ÿͻ�����ɾ��', '�����¼��ͻ�');
    Exit;
  end;

  nSQL := 'Select Count(*) From %s Where Z_Customer=''%s''';
  nSQL := Format(nSQL, [sTable_ZhiKa, nStr]);
  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('�ÿͻ�����ɾ��', '�Ѱ�ֽ��');
    Exit;
  end;

  nStr := SQLQuery.FieldByName('C_Name').AsString;
  if not QueryDlg('ȷ��Ҫɾ������Ϊ[ ' + nStr + ' ]�Ŀͻ���', sAsk) then Exit;

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

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('�ѳɹ�ɾ����¼', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ɾ����¼ʧ��', 'δ֪����');
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
  nParam: TFormCommandParam;
  nCus_ID,nCusName:string;
  nBindcustomerid:string;
  nWechartAccount:string;
  nStr:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ��ͨ�ļ�¼', sHint);
    Exit;
  end;
  nWechartAccount := SQLQuery.FieldByName('C_WechartAccount').AsString;
  if nWechartAccount<>'' then
  begin
    ShowMsg('�̳��˻�['+nWechartAccount+']�Ѵ���',sHint);
    Exit;
  end;

  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormGetWechartAccount, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    nBindcustomerid := PackerDecodeStr(nParam.FParamB);
    nWechartAccount := PackerDecodeStr(nParam.FParamC);
    nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
    nCusName := SQLQuery.FieldByName('C_Name').AsString;
    if not AddMallUser(nBindcustomerid,nCus_ID,nCusName) then Exit;
    
    nStr := 'update %s set C_WechartAccount=''%s'' where C_ID=''%s''';
    nStr := Format(nStr,[sTable_Customer,nWechartAccount,nCus_ID]);
    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nStr);
      FDM.ADOConn.CommitTrans;
      ShowMsg('�ͻ� [ '+nCusName+' ] �����̳��˻��ɹ���',sHint);
      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('�����̳��˻�ʧ��', 'δ֪����');
    end;
  end;
end;

procedure TfFrameCustomer_FP.N6Click(Sender: TObject);
var
  nWechartAccount:string;
  nStr:string;
  nCus_ID,nCusName:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫȡ���ļ�¼', sHint);
    Exit;
  end;
  nWechartAccount := SQLQuery.FieldByName('C_WechartAccount').AsString;
  if nWechartAccount='' then
  begin
    ShowMsg('�̳��˻����Ѵ���',sHint);
    Exit;
  end;

  nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
  nCusName := SQLQuery.FieldByName('C_Name').AsString;

  if not DelMallUser(nWechartAccount, nCus_ID) then Exit;
  nStr := 'update %s set C_WechartAccount='''' where C_ID=''%s''';
  nStr := Format(nStr,[sTable_Customer,nCus_ID]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nStr);
    FDM.ADOConn.CommitTrans;
    ShowMsg('�ͻ� [ '+nCusName+' ] ȡ���̳��˻����� �ɹ���',sHint);
    InitFormData(FWhere);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ȡ���̳��˻����� ʧ��', 'δ֪����');
  end;
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
  //���Ͱ����󿪻�����
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
    ShowMsg('�ͻ�[ '+nCus_num+' ]�����̳��˻�ʧ�ܣ�', sError);
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
  //����http����
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
    ShowMsg('�ͻ�[ '+nCus_id+' ]ȡ���̳��˻����� ʧ�ܣ�', sError);
    Exit;
  end;
  Result := True;
end;

initialization
  gControlManager.RegCtrl(TfFrameCustomer_FP, TfFrameCustomer_FP.FrameID);

end.
