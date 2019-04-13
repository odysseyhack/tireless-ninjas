<template>
  <div class="home">
    <div class="card-wrapper">
      <div class="card top-card">test</div>
      <div class="card top-card">test</div>
    </div>
  </div>
</template>

<script>

import ABI from "../../../blockchain/build/contracts/AddProduction.json";

import { web3 } from "../main.js";

export default {
  name: "home",
  data() {
    return {
      production: 0
    };
  },
  mounted() {},
  methods: {
    handleClick() {
      const contractAddress = "0xFB7aefbF88dBE674D7a65CbE7bCf95E3DfFa961c";

      const contract = new web3.eth.Contract(ABI.abi, contractAddress);

      contract.methods
        .set(this.production)
        .send(
          { from: "0xb38D567a4764153241B1bc8Fff47208F59edFA4B", gas: 400000 },
          (error, result) => {
            if (!error) {
              console.log(result);
            } else {
              console.log(error);
            }
          }
        );
    }
  },
  components: {
  }
};
</script>

<style lang="scss">
.top-card {
  background-color: white;
  margin-left: auto;
  margin-right: auto;
  left: 0;
  right: 0;
  width: 60%;
  height: 200px;
  margin-top: 300px;
  width: 48%;
}

.card {
  border-radius: 12px;
  box-shadow: 0 2px 44px 0 rgba(46, 46, 46, 0.09);
}

.home {
  background: url("../assets/header_img.svg") no-repeat;
  background-size: contain;
  height: 100vh;
  padding-right: 100px;
  padding-left: 100px;
}
.card-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>

