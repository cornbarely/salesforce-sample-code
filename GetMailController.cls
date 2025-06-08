public class GetMailController {

    public static List<String> getMail(mailInfo prms) {
        
        Id templateId = prms.templateId;
        Id whoId = prms.whoId;
        Id whatId = prms.whatId;
        Map<String, String> replaceMap = prms.replaceMap;
        
        // 差し込み完了後のメールテンプレートの件名、本文を取得
        Messaging.SingleEmailMessage email = 
            Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
        
        String subject = email.getSubject();
        String body = email.getPlainTextBody();

        // 置換が必要のある場合、マップ分置換処理を行う。
        if(replaceMap != null && !replaceMap.isEmpty()){
            for(String keyStr : replaceMap.keySet())
            body = body.replace(keyStr, replaceMap.get(keyStr));
        }
        
        // 件名と本文をリストに格納して返却
        List<String> strList = new List<String>();

        strList.add(subject);
        strList.add(body);
        
        return strList;
    }

    // メール送信用の引数クラス
    public class mailInfo {
        @InvocableVariable(required=true label='templateId')
        public Id templateId;
        @InvocableVariable(required=true label='whoId')
        public Id whoId;
        @InvocableVariable(required=true label='whatId')
        public Id whatId;
        public Map<String, String> replaceMap;
    }
}