<template>
  <div id="app">
    <Scrolly/>
  </div>
</template>

<script>
import Scrolly from './components/Scrolly.vue'

export default {
  name: 'app',
  components: {
    Scrolly
  }
}
</script>

<style>
  body {
    margin: 0px;
    font-family: Arial, Helvetica, sans-serif;
  }
</style>
