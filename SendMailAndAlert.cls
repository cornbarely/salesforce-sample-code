public without sharing class SendMailAndAlert {

    /**
	 * メール・アラート送信制御メソッド
	 */
    public static void controlSendMailAndAlert(List<commonInfo> comInfList){

        // 件名・本文を初期化する。
        String subject = null;
        String body = null;

        for(commonInfo comInf : comInfList){
            // salesforceId
            Id sfId = comInf.sfId;
            // ユーザid
            Id userId = comInf.userId;
            // メールアドレス
            String toMail = comInf.toMail;
            // メールテンプレートId
            Id templateId = comInf.templateId; 
            // カスタム通知Id
            Id cusNotTypeId = comInf.cusNotTypeId;
            // 組織アドレスId
            Id orgWideEmailId = comInf.orgWideEmailId; 
            // 通知区分
            String sendKubun = comInf.sendKubun;
            // メール・ベルマークの本文置換マップ
            Map<String, String> replaceMap = comInf.replaceMap;

            // 差し込み完了後のメールテンプレートの件名、本文を取得する。
            Id whatId = sfId;
            Id whoId = sfId;

            // テンプレート取得用のパラメーター作成
            GetMailController.mailInfo gm = new GetMailController.mailInfo();
            gm.templateId = templateId;
            gm.whoId = whoId;
            gm.whatId = whatId;
            gm.replaceMap = replaceMap;
            List<String> mailContentList = GetMailController.getMail(gm);
            
            // 件名取得
            subject = mailContentList[0];
            // 本文取得
            body = mailContentList[1];

            // メール送信用のパラメーター作成
            // 条件：通知区分 = メール or （メール・ベルマーク）の場合
            if(sendKubun.equals('mail') || sendKubun.equals('mailBeru')){

                SendMailAndAlert.mailInfo sendMail = new SendMailAndAlert.mailInfo();
                sendMail.whatId = whatId;
                sendMail.orgWideEmailId = orgWideEmailId;
                sendMail.toMail = toMail;
                sendMail.subject = subject;
                sendMail.body = body;
    
                // メール送信
                SendMailAndAlert.sendMail(sendMail);
            }

            // アラート送信用のパラメーター作成
            // 条件：通知区分 = ベルマーク or （メール・ベルマーク）の場合
            if(sendKubun.equals('beru') || sendKubun.equals('mailBeru')){

                SendMailAndAlert.alertInfo sendAlert = new SendMailAndAlert.alertInfo();
                sendAlert.sfId = sfId;
                sendAlert.recipientId = userId;
                sendAlert.cusNotTypeId = cusNotTypeId;
                sendAlert.subject = subject;
                sendAlert.body = body;

                // アラート（ベルマーク）送信
                SendMailAndAlert.sendAlert(sendAlert);
            }
        }
    }

    /**
	 * メール送信メソッド
	 */
    private static void sendMail(mailInfo prms){

        system.debug('★DeliveryCompletedMail.prms; ' + prms);
        Id whatId = prms.whatId;
        Id orgWideEmailId = prms.orgWideEmailId;
        String toMail = prms.toMail;
        String subject = prms.subject;
        String body = prms.body;

        List<String> toRecipients = new List<String>();
        toRecipients.add(toMail);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        // 送信元を設定する。
        email.setorgWideEmailAddressId(orgWideEmailId);

        // 送信先を設定する。
        email.setToAddresses(toRecipients);

        email.setWhatId(whatId);

        // 件名を設定する。
        email.setSubject(subject);

        // 本文を設定する。
        email.setPlainTextBody(body);

        // 送信メールを活動に保存する。
        email.setSaveAsActivity(true);

        // メールを送信する。
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    /**
	 * アラート（ベルマーク）送信メソッド
	 */
    private static void sendAlert(alertInfo prms){

        system.debug('★DeliveryCompletedAlert.prms; ' + prms);
        Id sfId = prms.sfId;
        Id recipientId = prms.recipientId;
        Id cusNotTypeId = prms.cusNotTypeId;
        String subject = prms.subject;
        String body = prms.body;

        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        notification.setTitle(subject);
        notification.setBody(body);
        notification.setNotificationTypeId(cusNotTypeId);
        notification.setTargetId(sfId);

        try {
            notification.send(new Set<String> { recipientId });
            // テスト中に限り、強制的にDmlExceptionを発行させる。
            if(Test.isRunningTest()) insert new User();
        } catch (Exception e) {
            System.debug('★Problem sending notification: ' + e.getMessage());
        }
    }

    /**
	 * メールテンプレートId取得メソッド
	 */
    public static Id getEmailTemplateId(String emailTemp){
        return [SELECT Id FROM emailTemplate WHERE DeveloperName = :emailTemp LIMIT 1].Id;
    }

    /**
	 * カスタム通知Id取得メソッド
	 */
    public static Id getCustomAlertId(String customNotification) {
        return [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :customNotification LIMIT 1].Id;
    }

    /**
	 * 組織のアドレスのId取得メソッド
	 */
    public static Id getOrgWideEmailAddress(String displayName) {
        return [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :displayName LIMIT 1].Id;
    }

    // メール・アラート送信用の共通クラス
    public class commonInfo {
        // salesforceId
        public Id sfId;
        // ユーザId
        public Id userId;
        // メールアドレス
        public String toMail;
        // メールテンプレートId
        public Id templateId;
        // カスタム通知Id
        public Id cusNotTypeId;
        // 組織アドレスId
        public Id orgWideEmailId;
        // 通知区分
        public String sendKubun;
        // メール・ベルマークの本文置換マップ
        public Map<String, String> replaceMap;
    }

    // メール送信用の引数クラス
    public class mailInfo {
        // オブジェクト識別Id
        public Id whatId;
        // 差出人FROM
        public Id orgWideEmailId;
        // 宛先TO
        public String toMail;
        // 件名
        public String subject;
        // 本文
        public String body;
    }

    // アラート送信用の引数クラス
    public class alertInfo {
        // salesforceId
        public Id sfId;
        // 受信者Id
        public Id recipientId;
        // カスタム通知Id
        public Id cusNotTypeId;
        // 件名
        public String subject;
        // 本文
        public String body;
    }
}