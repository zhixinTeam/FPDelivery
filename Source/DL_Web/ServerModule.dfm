object UniServerModule: TUniServerModule
  OldCreateOrder = False
  TempFolder = 'temp\'
  Title = 'New Application'
  Favicon.Data = {
    0000010001001010000001002000680400001600000028000000100000002000
    0000010020000000000040040000000000000000000000000000000000000000
    0000727272FF727272FF727272FF727272FF7272729F00000000B17D4A50B17D
    4ADFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AEFB17D4A600000
    0000727272FFFFFFFFFFFFFFFFFFFFFFFFFF00000000B17D4AEFB17D4AFFB17D
    4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFF0000
    0000727272FFFFFFFFFF97A776FFFFFFFFFF00000000B17D4AFFB17D4AFFB17D
    4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4ABF0000
    0000727272FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF40B17D4A70B17D4AFFB17D
    4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4A80000000000000
    0000727272FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFF40B17D4A10B17D
    4ACFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4AFFB17D4ABF000000000000
    0000727272FF727272FF727272FF727272FF727272FF727272FF72727280B17D
    4A60B17D4AFFB17D4AFFB17D4ACFB17D4A30B17D4A9FB17D4A40000000000000
    0000727272FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF727272EF0000
    0000B17D4A30B17D4A40B17D4A10000000000000000000000000000000000000
    0000727272FF727272FF727272FF727272FF727272FF727272FF727272FF0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000727272FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF727272FF0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000727272FF727272FF727272FF727272FF727272FF727272FF727272FF0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000727272FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF727272FF0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000727272FFFFFFFFFF727272FF727272FF727272FFFFFFFFFF727272FF0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000727272FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF727272FF0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000727272FF727272FF727272FF727272FF727272FF727272FF727272FF0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  SuppressErrors = []
  Bindings = <>
  MainFormDisplayMode = mfPage
  ServerMessages.UnavailableErrMsg = #36890#35759#38169#35823': '#25968#25454#26080#27861#27491#30830#20256#36755
  ServerMessages.LoadingMessage = #27491#22312#35835#21462
  ServerMessages.ExceptionTemplate.Strings = (
    '<html>'
    '<body bgcolor="#dfe8f6">'
    '<p style="text-align:center;color:#A05050">'#31995#32479#21457#29983#38169#35823','#25551#36848#22914#19979':</p>'
    '<p style="text-align:center;color:#0000A0">[###message###]</p>'
    
      '<p style="text-align:center;color:#A05050"><a href="[###url###]"' +
      '>'#37325#26032#30331#24405#31995#32479'</a></p>'
    '</body>'
    '</html>')
  ServerMessages.InvalidSessionTemplate.Strings = (
    '<html>'
    '<body bgcolor="#dfe8f6">'
    '<p style="text-align:center;color:#0000A0">[###message###]</p>'
    
      '<p style="text-align:center;color:#A05050"><a href="[###url###]"' +
      '>'#37325#26032#30331#24405#31995#32479'</a></p>'
    '</body>'
    '</html>')
  ServerMessages.TerminateTemplate.Strings = (
    '<html>'
    '<body bgcolor="#dfe8f6">'
    '<p style="text-align:center;color:#0000A0">[###message###]</p>'
    
      '<p style="text-align:center;color:#A05050"><a href="[###url###]"' +
      '>'#37325#26032#30331#24405#31995#32479'</a></p>'
    '</body>'
    '</html>')
  ServerMessages.InvalidSessionMessage = #27809#26377#30331#24405' '#25110' '#30331#24405#36229#26102
  ServerMessages.TerminateMessage = #24744#24050#36864#20986#31995#32479
  SSL.SSLOptions.RootCertFile = 'root.pem'
  SSL.SSLOptions.CertFile = 'cert.pem'
  SSL.SSLOptions.KeyFile = 'key.pem'
  SSL.SSLOptions.Method = sslvTLSv1_1
  SSL.SSLOptions.SSLVersions = [sslvTLSv1_1]
  SSL.SSLOptions.Mode = sslmUnassigned
  SSL.SSLOptions.VerifyMode = []
  SSL.SSLOptions.VerifyDepth = 0
  Options = [soAutoPlatformSwitch, soRestartSessionOnTimeout, soWipeShadowSessions]
  ConnectionFailureRecovery.ErrorMessage = 'Connection Error'
  ConnectionFailureRecovery.RetryMessage = 'Retrying...'
  OnBeforeInit = UniGUIServerModuleBeforeInit
  OnBeforeShutdown = UniGUIServerModuleBeforeShutdown
  Height = 346
  Width = 524
end
