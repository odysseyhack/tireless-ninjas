<template>
  <div class="home">
    <div class="card-wrapper">
      <div class="card top-card">
        <div class="small-card-content">
          <img src="../assets/ic_energy.svg" alt="">
          <div class="vertical-text">
            <span class="small-label">Green energy produced</span>
            <span class="green-production">2397 kWh</span>
          </div>
        </div>
      </div>
      <div class="card top-card">
        <div class="small-card-content">
          <img src="../assets/ic_certificate.svg" alt="">
          <div class="vertical-text">
            <h2 class="certificates">5 certificates</h2>
            <span class="small-label">Last certificate granted Jan 1 2019</span>
          </div>
        </div>
      </div>
    </div>
    <div class="card large-card">

        <div class="chart-container">
          <line-chart
            :chartdata="chartdata"
            :options="options"/>
        </div>
      </div>
  </div>
</template>

<script>

import ABI from "../../../blockchain/build/contracts/AddProduction.json";

import householdData from '../data/data.json'; 

import { web3 } from "../main.js";

import LineChart from '../components/LineChart.vue';

export default {
  name: "home",
  data() {
    return {
      production: 0,
      productionList: [],
      timeList: [],
      chartdata: {
        labels: [],
        datasets: [
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        legend: {
          display: false
        },
        scales: {
          xAxes: [{
              gridLines: {
                  display:false
              },
              scaleLabel: {
                display: true,
                labelString: 'Time',
                fontStyle: 'bold'
              }
          }],
          yAxes: [{
              gridLines: {
                  display:false
              },
              scaleLabel: {
                display: true,
                labelString: 'Production in MWh',
                fontStyle: 'bold'
              }   
          }]
        }
      }
    };
  },
  mounted() {

    this.productionList = this.getValues(householdData, 'Cumulative');
    this.timeList = this.getValues(householdData, 'Datum');
    this.fillData();
  },
  methods: {
    fillData() {
      this.chartdata = {
        labels: this.timeList,
        datasets: [
          {
            label: '',
            backgroundColor: 'transparent',
            borderColor: '#FD8179',
            data: this.productionList
          }
        ]
      }
    },
    getValues(arrayOfObjects, key) {
      let result = [];
      for(let element of arrayOfObjects) {
        result.push(element[key]);
      }
      return result;
    },
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
    LineChart
  }
};
</script>

<style lang="scss">

.certificates {
  margin: 0;
}
.large-card {
  margin-top: 100px;
}
.small-card-content {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  height: 100%;
  padding-right: 50px;
  padding-left: 50px;
}
.green-production {
  font-size: 4rem;
  font-weight: bold;
  color: #FD8179;
}
.vertical-text {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  margin-left: 40px;
}
.small-label {
  font-size: 1rem;
  font-weight: 500;
}
.full-width {
  width: 100%;
}
.top-card {
  left: 0;
  right: 0;
  width: 60%;
  height: 140px;
  margin-top: 300px;
  width: 44%;
}

.card {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 44px 0 rgba(46, 46, 46, 0.09);
  padding: 20px;
}

.home {
  background: url("../assets/header_img.svg") no-repeat;
  background-size: contain;
  height: 100vh;
  padding-right: 200px;
  padding-left: 200px;
}
.card-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>

