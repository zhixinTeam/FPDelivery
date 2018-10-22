{*******************************************************************************
  ����: dmzn@163.com 2018-05-03
  ����: Զ��ҵ�����
*******************************************************************************}
unit USysRemote;

{$I Link.Inc}
interface

uses
  Windows, Classes, System.SysUtils, UClientWorker, UBusinessConst,
  UBusinessPacker, UManagerGroup, USysDB, USysConst;

implementation

//Date: 2018-05-03
//Parm: ����;����;����;���
//Desc: �����м���ϵ�ҵ���������
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TClient2MITWorker;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gMG.FObjectPool.Lock(TClientBusinessCommand) as TClient2MITWorker;
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      nWorker.WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nWorker);
  end;
end;

end.


