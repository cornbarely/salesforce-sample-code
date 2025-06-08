public without sharing class AccountTriggerHandler {

    // 定数を宣言
    private final String systemAdministratorProfile = System.Label.SystemAdministratorProfileName ;
    private final String emailTemp = 'CusInfoChangeEmailTemplate';
    private final String customNotification = 'CusInfoChangeNotification';
    private final String sendKubun = 'mailBeru';
    private final String displayName = 'システム通知';

    /**
     * Is after update
     */
    public void isAfterUpdate(List<Account> newList) {

        // お客様情報の変更通知処理を行う。
        this.cusInfoChangeNotification(newList);
    }

	/**
	 * お客様情報の変更通知処理メソッド
	 */
    private void cusInfoChangeNotification(List<Account> newList){

        // 以下条件を満たす場合、取引先を取得する。
        // 1. 引数で取得した取引先リストのIdに含まれる
        // 2. 取引先所有者のユーザが「有効」である
        List<Account> accList = [
                                    SELECT 
                                        Id
                                        , Owner.Id
                                        , Owner.Email
                                    FROM Account 
                                    WHERE Id IN :newList
                                    AND Owner.IsActive = TRUE
                                ];

        if(accList.isEmpty()) return;

        // メールテンプレートId取得
        Id templateId = SendMailAndAlert.getEmailTemplateId(emailTemp);

        // カスタム通知Id取得
        Id cusNotTypeId = SendMailAndAlert.getCustomAlertId(customNotification);

        // 組織のアドレスのId取得
        Id orgWideEmailId = SendMailAndAlert.getOrgWideEmailAddress(displayName);
        
        List<SendMailAndAlert.commonInfo> commonInfoList = new List<SendMailAndAlert.commonInfo>();
        for(Account acc : accList){

            SendMailAndAlert.commonInfo sma = new SendMailAndAlert.commonInfo();
            sma.sfId = acc.Id;
            sma.userId = acc.Owner.Id;
            sma.toMail = acc.Owner.Email;
            sma.templateId = templateId;
            sma.cusNotTypeId = cusNotTypeId;
            sma.orgWideEmailId = orgWideEmailId;
            sma.sendKubun = sendKubun;

            commonInfoList.add(sma);
        }

        // メール・ベルマーク（アラート）を送信する。
        SendMailAndAlert.controlSendMailAndAlert(commonInfoList);
    }
}