<template>
  <div class="wrapper" @click="update">
    <!-- <image :src="logoUrl" class="logo"></image> -->
    <image style="width:100px;height:100px" src="https://vuejs.org/images/logo.png"></image>
    <text class="title">Hello {{target}}</text>
    <text>扫码结果：{{resultString}}</text>

   <div @click="printAction" class="button">
      <text style="color:#fff">开始扫码</text>
   </div>
   <div @click="generateAction" class="generateButton">
      <text style="color:#fff">生成二维码(www.baidu.com)</text>
   </div>
  <text>生成二维码结果：{{generateResult}}</text>
  <div>
    <image :src="src" style="width: 196px; height: 196px;" ></image>
  </div>
  </div>

  

</template>

<style>
  .wrapper { align-items: center; margin-top: 120px; }
  .title { padding-top:40px; padding-bottom: 40px; font-size: 48px; }
  /* .logo { width: 360px; height: 156px; } */

  .button {
    margin: 20px;
    padding:20px;
    background-color:#1ba1e2;
    color:#fff;
  }

  .generateButton {
    margin: 20px;
    padding:20px;
    background-color:#1ba1e2;
    color:#fff;
  }

</style>

<script>
  var scanner = weex.requireModule('wxQRCode')

  export default {

    init: function () {
    },
    created: function(){
    },

    ready: function () {
    },
    destroyed: function () {
    },

    data: {    
      resultString : "暂无结果",
      generateResult:"未生成二维码",
      src: ''
    },

    methods: {

      printAction: function() {

        var _this = this;
        var params = {};

        scanner.scanQRCode( function (result) {
          console.log(result);
          
          _this.resultString = result
        });
      },
      generateAction: function() {

        var _this = this;
        
        var params = {"width":"300","height":"300","content":"https://www.baidu.com"};
        scanner.createQRCode(params, function (result) {
          console.log(result);
          
          _this.generateResult = result;
          _this.src = result['result'];
        });
      }

    }
  }
</script>
