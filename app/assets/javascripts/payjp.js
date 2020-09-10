$(function() {
  Payjp.setPublicKey('pk_test_595999dca3469563e4e80032');
  $("#charge_form").on('click', function(e){
    e.preventDefault(); //「追加する」のクリックイベントが行われた時に動作を一度停止
    var year = $("#exp_year").val()
    var month = $("#exp_month").val()
    exp_year = String(year);
    exp_month= String(month);
    let card = { //カード登録に入力された情報をハッシュで格納
      number: $("#number").val(),
      cvc: $("#cvc").val(), 
      exp_month: exp_month,
      exp_year: exp_year
    };
    //PAY.JPのサーバーと通信し、カード情報を送信することで認証を行い、カードトークンをresponse.idで受けとる。
    Payjp.createToken(card, function(status, response){
      if (status === 200) {  //サーバーとのやり取りが200=正常に行えた場合
        $("#all-form").append(
          $('<input type="hidden" name="payjp-token">').val(response.id)
        );
        $('#all-form').submit();  //all-formはform_withのidであり、createアクションにparamsを送信します。
      } else {
        alert("カード情報が正しくありません。");
      }
    });
  });
});