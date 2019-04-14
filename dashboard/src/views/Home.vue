<template>
  <div class="home">
    <div class="card-wrapper">
      <div class="card top-card">
        <div class="small-card-content">
          <img src="../assets/ic_energy.svg" alt="">
          <div class="vertical-text">
            <span class="small-label">Tradable green energy produced</span>
            <span class="green-production">{{totalTradable}} kWh</span>
          </div>
        </div>
      </div>
      <div class="card top-card">
        <div class="small-card-content">
          <img src="../assets/ic_certificate.svg" alt="">
          <div class="vertical-text">
            <h2 class="certificates">{{ tradableCertificates }} tradable certificates</h2>
            <span class="small-label">Last certificate granted {{ dateLatestTradable }}</span>
          </div>
        </div>
      </div>
    </div>
    <div class="card-wrapper" style="margin-top: -250px;">
      <div class="card top-card">
        <div class="small-card-content">
          <img src="../assets/ic_energy.svg" alt="">
          <div class="vertical-text">
            <span class="small-label">Non-tradable green energy produced</span>
            <span class="green-production">{{totalNontradable}} kWh</span>
          </div>
        </div>
      </div>
      <div class="card top-card">
        <div class="small-card-content">
          <img src="../assets/ic_certificate.svg" alt="">
          <div class="vertical-text">
            <h2 class="certificates">{{ nonTradableCertificates }} non-tradable certificates</h2>
            <span class="small-label">Last certificate granted {{ dateLatestNonTradable }}</span>
          </div>
        </div>
      </div>
    </div>
    <div class="card large-card">
        <h2>Your green energy profile</h2>
        
        <div class="chart-container">
          <line-chart
            :chartData="chartdata"
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

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export default {
  name: "home",
  data() {
    return {
      production: 0,
      productionList: [],
      tradableList: [],
      nonTradableList: [],
      totalTradable: 0,
      totalNontradable: 0,
      tradableCertificates: 0,
      nonTradableCertificates: 0,
      dateLatestTradable: null,
      dateLatestNonTradable: null,
      colorArray: [],
      pointRadiusArray: [],
      timeList: [],
      chartdata: null,
      options: null,
      currentEnergy: ''
    };
  },
  mounted() {

    this.tradableList = this.getValues(householdData, 'Tcumulative');
    this.nonTradableList = this.getValues(householdData, 'Ncumulative');

    this.timeList = this.getValues(householdData, 'Datum');

    this.totalTradable = parseFloat(this.getTotalProduced(householdData, 'Tcumulative')) * -1;
    this.totalNontradable = parseFloat(this.getTotalProduced(householdData, 'Ncumulative')) * -1;
    this.tradableCertificates = Math.round(this.totalTradable / 10);
    this.nonTradableCertificates = Math.round(this.totalNontradable / 10);
    this.dateLatestTradable = this.getDateLatestCertificate(householdData, 'TGO');
    this.dateLatestNonTradable = this.getDateLatestCertificate(householdData, 'NTGO');

    this.fillData();
    this.setOptions();
  },
  methods: {
    
    setOptions() {
      this.options = {
        responsive: true,
        maintainAspectRatio: false,
        // legend: {
        //   display: false
        // },
        scales: {
          xAxes: [{
              gridLines: {
                  display:false
              },
              scaleLabel: {
                display: true,
                labelString: 'Date',
                fontStyle: 'bold'
              }
          }],
          yAxes: [{
              gridLines: {
                  display:false
              },
              scaleLabel: {
                display: true,
                labelString: 'Production in kWh',
                fontStyle: 'bold'
              }   
          }]
        },
        tooltips: {
          callbacks: {
            label: function(tooltipItem, data) {
              let label = '';
              let borderColor = data.datasets[tooltipItem.datasetIndex].pointBackgroundColor[tooltipItem.index];
              if (borderColor === '#00ff00') {
                label = tooltipItem.yLabel + ' kWh => ' + 'TGO issued';
              } else {
                label = 'Energy: ' + tooltipItem.yLabel + ' kWh';
              }
              return label;
            }
          }
        }
      };
    },
    fillData() {
      this.chartdata = {
        labels: this.timeList,
        datasets: [
          {
            label: 'Tradable',
            backgroundColor: 'transparent',
            borderColor: '#FD8179',
            data: this.tradableList,
            pointBackgroundColor: this.colorArray,
            pointBorderColor: this.colorArray,
            pointRadius: this.pointRadiusArray
          },
          {
            label: 'Non-tradable',
            backgroundColor: 'transparent',
            borderColor: 'blue',
            data: this.nonTradableList,
            pointBackgroundColor: this.colorArray,
            pointBorderColor: this.colorArray,
            pointRadius: this.pointRadiusArray
          }
        ]
      }
    },
    getDateLatestCertificate(arrayOfObjects, key) {
      let tgos = arrayOfObjects.filter((element) => element[key] === 'Yes');
      let date = new Date(tgos[tgos.length - 1]['Datum']);
      return date.getDate() + ' ' + months[date.getMonth()] + ' ' + date.getFullYear();
    },
    getTotalProduced(arrayOfObjects, key) {
      return arrayOfObjects[arrayOfObjects.length - 1][key];
    },
    getValues(arrayOfObjects, key, min, max) {
      let result = [];
      let mininmum = min || 0;
      let maximum = max || arrayOfObjects.length - 1; 
      for(let i = mininmum; i < maximum; i++) {
          let value = '';
          if (key === 'Ncumulative' || key === 'Tcumulative') {
            value = parseFloat(arrayOfObjects[i][key]) * -1;
          } else {
            value = new Date(arrayOfObjects[i][key]).getDate() + '-' + (new Date(arrayOfObjects[i][key]).getMonth() + 1) + '-' + new Date(arrayOfObjects[i][key]).getFullYear();
          }
          result.push(value);
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
.chart-bar {
  display: flex;
  align-content: center;
  justify-content: space-evenly;
}
.certificates {
  margin: 0;
}
.large-card {
  margin-top: 60px;
  margin-bottom: 40px;
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

