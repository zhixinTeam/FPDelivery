{*******************************************************************************
  ����: dmzn@ylsoft.com 2018-03-15
  ����: ��Ŀͨ�ó�,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

interface

uses
  SysUtils, Classes, Data.DB, uniPageControl;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cSBar_User            = 2;                         //�û��������
  cRecMenuMax           = 5;                         //���ʹ�õ����������Ŀ��

  {*Command*}
  cCmd_RefreshData      = $0002;                     //ˢ������
  cCmd_ViewSysLog       = $0003;                     //ϵͳ��־

  cCmd_ModalResult      = $1001;                     //Modal����
  cCmd_FormClose        = $1002;                     //�رմ���
  cCmd_AddData          = $1003;                     //��������
  cCmd_EditData         = $1005;                     //�޸�����
  cCmd_ViewData         = $1006;                     //�鿴����
  cCmd_GetData          = $1007;                     //ѡ������
  cCmd_ShenHe           = $1008;                     //�������

type
  TAdoConnectionType = (ctMain, ctWork);
  //��������

  PAdoConnectionData = ^TAdoConnectionData;
  TAdoConnectionData = record
    FConnUser : string;                              //�û����������ַ���
    FConnStr  : string;                              //ϵͳ��Ч�����ַ���
    FConnected: Boolean;                             //����״̬
    FConneLast: Int64;                               //�ϴλ
  end;
  //���Ӷ�������

  TFactoryItem = record
    FFactoryID  : string;                            //�������
    FFactoryName: string;                            //��������
    FFactoryIdx : Integer;                           //��������

    FMITServURL : string;                            //ҵ�����
    FHardMonURL : string;                            //Ӳ���ػ�
    FWechatURL  : string;                            //΢�ŷ���
    FDBWorkOn   : string;                            //�������ݿ�
  end;

  TFactoryItems = array of TFactoryItem;
  //�����б�

  PSysParam = ^TSysParam;
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�
    FCopyRight  : string;                            //��������ʾ����

    FUserID     : string;                            //�û���ʶ
    FUserName   : string;                            //��ǰ�û�
    FUserPwd    : string;                            //�û�����
    FGroupID    : string;                            //������
    FIsAdmin    : Boolean;                           //�Ƿ����Ա

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    FOSUser     : string;                            //����ϵͳ
    FUserAgent  : string;                            //���������
    FFactory    : Integer;                           //������������
  end;
  //ϵͳ����

  TServerParam = record
    FPort       : Integer;                           //����˿�
    FExtJS      : string;                            //ext�ű�Ŀ¼
    FUniJS      : string;                            //uni�ű�Ŀ¼
    FDBMain     : string;                            //�����ݿ�����
  end;

  TModuleItemType = (mtFrame, mtForm);
  //ģ������

  PMenuModuleItem = ^TMenuModuleItem;
  TMenuModuleItem = record
    FMenuID: string;                                 //�˵�����
    FModule: string;                                 //ģ������
    FTabSheet: TUniTabSheet;                         //����ҳ��
    FItemType: TModuleItemType;                      //ģ������
  end;

  TMenuModuleItems = array of TMenuModuleItem;       //ģ���б�

  PFormCommandParam = ^TFormCommandParam;
  TFormCommandParam = record
    FCommand: integer;                               //����
    FParamA: Variant;
    FParamB: Variant;
    FParamC: Variant;
    FParamD: Variant;
    FParamE: Variant;                                //����A-E
  end;

  TFormModalResult = reference to  procedure(const nResult: Integer;
    const nParam: PFormCommandParam = nil);
  //ģʽ�������ص�

  //----------------------------------------------------------------------------
  PMenuItemData = ^TMenuItemData;
  TMenuItemData = record
    FProgID: string;                                 //�����ʶ
    FEntity: string;                                 //ʵ���ʶ
    FMenuID: string;                                 //�˵���ʶ
    FPMenu: string;                                  //�ϼ��˵�
    FTitle: string;                                  //�˵�����
    FImgIndex: integer;                              //ͼ������
    FFlag: string;                                   //���Ӳ���(�»���..)
    FAction: string;                                 //�˵�����
    FFilter: string;                                 //��������
    FNewOrder: Single;                               //��������
    FLangID: string;                                 //���Ա�ʶ
  end;

  TMenuItems = array of TMenuItemData;
  //�˵��б�

  TPopedomItemData = record
    FItem: string;                                   //����
    FPopedom: string;                                //Ȩ��
  end;
  TPopedomItems = array of TPopedomItemData;

  TPopedomGroupItem = record
    FID: string;                                     //���ʶ
    FName: string;                                   //������
    FDesc: string;                                   //������
    FUser: TStrings;                                 //�����û�
    FPopedom: TPopedomItems;                         //Ȩ���б�
  end;

  TPopedomGroupItems = array of TPopedomGroupItem;
  //Ȩ���б�

  //----------------------------------------------------------------------------
  TDictFormatStyle = (fsNone, fsFixed, fsSQL, fsCheckBox);
  //��ʽ����ʽ: �̶�����,���ݿ�����

  PDictFormatItem = ^TDictFormatItem;
  TDictFormatItem = record
    FStyle: TDictFormatStyle;                        //��ʽ
    FData: string;                                   //����
    FFormat: string;                                 //��ʽ��
    FExtMemo: string;                                //��չ����
  end;

  PDictDBItem = ^TDictDBItem;
  TDictDBItem = record
    FTable: string;                                  //����
    FField: string;                                  //�ֶ�
    FIsKey: Boolean;                                 //����

    FType: TFieldType;                               //��������
    FWidth: integer;                                 //�ֶο���
    FDecimal: integer;                               //С��λ
  end;

  TDictFooterKind = (fkNone, fkSum, fkMin, fkMax, fkCount, fkAverage);
  //ͳ������: ��,�ϼ�,��С,���,��Ŀ,ƽ��ֵ
  TDictFooterPosition = (fpNone, fpFooter, fpGroup, fpAll);
  //�ϼ�λ��: ҳ��,����,���߶���

  PDictGroupFooter = ^TDictGroupFooter;
  TDictGroupFooter = record
    FDisplay: string;                               //��ʾ�ı�
    FFormat: string;                                //��ʽ��
    FKind: TDictFooterKind;                         //�ϼ�����
    FPosition: TDictFooterPosition;                 //�ϼ�λ��
  end;

  PDictItemData = ^TDictItemData;
  TDictItemData = record
    FItemID: integer;                               //��ʶ
    FTitle: string;                                 //����
    FAlign: TAlignment;                             //����
    FWidth: integer;                                //����
    FIndex: integer;                                //˳��
    FVisible: Boolean;                              //�ɼ�
    FLangID: string;                                //����
    FDBItem: TDictDBItem;                           //���ݿ�
    FFormat: TDictFormatItem;                       //��ʽ��
    FFooter: TDictGroupFooter;                      //ҳ�źϼ�
  end;
  TDictItems = array of TDictItemData;

  PEntityItemData = ^TEntityItemData;
  TEntityItemData = record
    FEntity: string;                                //ʵ����
    FTitle: string;                                 //ʵ������
    FDictItem: TDictItems;                          //�ֵ�����,һ��TDictItemData
  end;

  TEntityItems = array of TEntityItemData;
  //ʵ���б�

//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gServerParam: TServerParam;                        //����������

  gAllFactorys: TFactoryItems;                       //ϵͳ��Ч�����б�
  gAllPopedoms: TPopedomGroupItems;                  //Ȩ���б�
  gAllEntitys: TEntityItems;                         //�����ֵ�ʵ���б�

  gAllUsers: TList;                                  //�ѵ�¼�û��б�
  gAllMenus: TMenuItems;                             //ϵͳ��Ч�˵�
  gMenuModule: TList = nil;                          //�˵�ģ��ӳ���

//------------------------------------------------------------------------------

const
  {*url parameter or url router*}
  sMethod_FactoryStatus = 'factory_status';          //��������״̬

ResourceString
  sProgID             = 'DMZN';                      //Ĭ�ϱ�ʶ
  sAppTitle           = 'DMZN';                      //�������
  sMainCaption        = 'DMZN';                      //�����ڱ���

  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = 'δ֪����';                  //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogExt             = '.log';                      //��־��չ��
  sLogField           = #9;                          //��¼�ָ���

  sImageDir           = 'Images\';                   //ͼƬĿ¼
  sReportDir          = 'Report\';                   //����Ŀ¼
  sBackupDir          = 'Backup\';                   //����Ŀ¼
  sBackupFile         = 'Bacup.idx';                 //��������
  sCameraDir          = 'Camera\';                   //ץ��Ŀ¼

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������

  sFormConfig         = 'FormInfo.ini';              //��������
  sSetupSec           = 'Setup';                     //����С��
  sDBConfig           = 'DBConn.ini';                //��������
  sDBConfig_bk        = 'isbk';                      //���ݿ�

  sExportExt          = '.txt';                      //����Ĭ����չ��
  sExportFilter       = '�ı�(*.txt)|*.txt|�����ļ�(*.*)|*.*';
                                                     //������������ 

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

  sWebFlag            = 'web';                       //�˵���ʶ
  sCheckFlag          = '��';                         //ѡ�б��
  sMenuArea           = 'menu_area';                 //����˵���
  sEvent_StrGridColumnResize = 'StrGridColResize';   //��������б�

implementation

//------------------------------------------------------------------------------
//Desc: ���Ӳ˵�ģ��ӳ����
procedure AddMenuModuleItem(const nMenu,nModule: string;
 const nType: TModuleItemType = mtFrame);
var nItem: PMenuModuleItem;
begin
  New(nItem);
  gMenuModule.Add(nItem);

  nItem.FMenuID := nMenu;
  nItem.FModule := nModule;
  nItem.FTabSheet := nil;
  nItem.FItemType := nType;
end;

//Desc: �˵�ģ��ӳ���
procedure InitMenuModuleList;
begin
  gMenuModule := TList.Create;

  AddMenuModuleItem('MAIN_A01', '', mtForm);
  AddMenuModuleItem('MAIN_A05', 'TfFormChangePwd', mtForm);
  AddMenuModuleItem('MAIN_A06', 'TfFormOptions', mtForm);
  AddMenuModuleItem('MAIN_A07', 'TfFramePopedom');
  AddMenuModuleItem('SYSCLOSE', 'TfFormExit', mtForm);
  AddMenuModuleItem('MAIN_J09', 'TfFrameQryBills');
  AddMenuModuleItem('MAIN_J02', 'TfFrameQryMoney');
  AddMenuModuleItem('MAIN_J03', 'TfFrameTouSu');
  AddMenuModuleItem('MAIN_J04', 'TfFrameQryHuaYan');
  AddMenuModuleItem('MAIN_J05', 'TfFrameSHUser');
  AddMenuModuleItem('MAIN_J06', 'TfFrameFP');
  AddMenuModuleItem('MAIN_J07', 'TfFrameSQRec');
  AddMenuModuleItem('MAIN_J08', 'TfFrameBindCus');
  AddMenuModuleItem('MAIN_J10', 'TfFrameInvoiceInfo');
end;

//Desc: ����ģ���б�
procedure ClearMenuModuleList;
var nIdx: integer;
begin
  for nIdx:=gMenuModule.Count - 1 downto 0 do
  begin
    Dispose(PMenuModuleItem(gMenuModule[nIdx]));
    gMenuModule.Delete(nIdx);
  end;

  FreeAndNil(gMenuModule);
end;

initialization
  SetLength(gAllFactorys, 0);
  SetLength(gAllMenus, 0);
  SetLength(gAllPopedoms, 0);
  SetLength(gAllEntitys, 0);

  InitMenuModuleList;
  gAllUsers := TList.Create;
finalization
  FreeAndNil(gAllUsers);
  ClearMenuModuleList;
end.

