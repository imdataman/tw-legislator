<template>
  <div id="main">
  </div>
</template>

<script>
import * as d3 from "d3";
import 'intersection-observer';
import scrollama from 'scrollama';

export default {
  name: 'Scrolly',
  mounted() {
    const MOBILE = navigator.userAgent.match(/Android/i)
      || navigator.userAgent.match(/webOS/i)
      || navigator.userAgent.match(/iPhone/i)
      || navigator.userAgent.match(/iPad/i)
      || navigator.userAgent.match(/iPod/i)
      || navigator.userAgent.match(/BlackBerry/i)
      || navigator.userAgent.match(/Windows Phone/i);
    
    const CIRCLE_RADIUS = MOBILE? 10 : 30,
        COLLIDE_RADIUS = CIRCLE_RADIUS * 1.2,
        STRENGTH = 1.5,
        WIDTH = window.innerWidth,
        HEIGHT = window.innerHeight,
        LEFT_POSITION = 0,
        RIGHT_POSITION = WIDTH * (6 / 10),
        UPPER_POSITION = 0,
        LOWER_POSITION = HEIGHT * (6 / 10),
        CENTER = [WIDTH / 2, HEIGHT / 2];

    const ageScaleDesktop = d3.scaleLinear([20, 80], [0, WIDTH]);
    const ageScaleMobile = d3.scaleLinear([20, 80], [0, HEIGHT]);

    const scrollScript = [{
            step: 0,
            desktop() {
                return d3.forceX(() => CENTER[0]).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(() => CENTER[0]).strength(STRENGTH)
            },
        },
        {
            step: 1,
            desktop() {
                return d3.forceX(d => (d.party == '民主進步黨') ? LEFT_POSITION : 
                (d.party == '中國國民黨') ? RIGHT_POSITION : CENTER[0] * (3 / 5)).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => (d.party == '民主進步黨') ? UPPER_POSITION : 
                (d.party == '中國國民黨') ? LOWER_POSITION : CENTER[1] * (3 / 5)).strength(STRENGTH)
            },
        },
        {
            step: 2,
            desktop() {
                return d3.forceX(d => ageScaleDesktop(d.age)).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => ageScaleMobile(d.age)).strength(STRENGTH)
            },
        },
        {
            step: 3,
            desktop() {
                return d3.forceX(d => (d.term == 1) ? LEFT_POSITION : 
                (d.term < 6) ? CENTER[0] * (3 / 5) : RIGHT_POSITION).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => (d.term == 1) ? UPPER_POSITION : 
                (d.term < 6) ? CENTER[1] * (3 / 5) : LOWER_POSITION).strength(STRENGTH)
            },
        },
        {
            step: 4,
            desktop() {
                return d3.forceX(d => (d.gender == '男') ? WIDTH / 6 : RIGHT_POSITION).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => (d.gender == '男') ? HEIGHT / 6 : LOWER_POSITION).strength(STRENGTH)
            },
        },
    ];

    const section = d3.select('#main').append('section').attr('id', 'scrolly');

    section.append('article')
        .selectAll('.step')
        .data(scrollScript)
        .enter().append('div')
        .attr('class', 'step')
        .append('p')
        .text("123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123123");

    const svg = d3.select('#scrolly').append('svg');
    const g = svg.append('g').attr('id', 'vis');

    const forceX = d3.forceX(CENTER[0])
        .strength(0.5);

    const forceY = d3.forceY(CENTER[1])
        .strength(0.5);
    
    const simulation = d3.forceSimulation()

    if (MOBILE) {
      simulation.force('y', scrollScript[0].mobile())
        .force('x', forceX)
        .force('center', d3.forceCenter(CENTER[0], CENTER[1]))
        .force('collide', d3.forceCollide(() => COLLIDE_RADIUS).strength(STRENGTH).iterations(100));
    } else {
      simulation.force('x', scrollScript[0].desktop())
        .force('y', forceY)
        .force('center', d3.forceCenter(CENTER[0], CENTER[1]))
        .force('collide', d3.forceCollide(() => COLLIDE_RADIUS).strength(STRENGTH).iterations(100));
    }

    const scroller = scrollama();

    async function init() {
        const data = await d3.csv("./data/legislator_full.csv");

        scroller.setup({
                step: '#scrolly article .step',
                offset: 0.5
            })
            .onStepEnter(handleStepEnter);

        window.addEventListener('resize', scroller.resize);

        const circles = g.selectAll('.node')
            .data(data)
            .enter().append('svg:image')
            .attr('class', 'node')
            .attr('width', () => CIRCLE_RADIUS * 2)
            .attr('height', () => CIRCLE_RADIUS * 2)
            .attr("xlink:href", d => './image/' + d.id + '.png');

        simulation.nodes(data)
            .on('tick', ticked);

        function ticked() {
            circles
                .attr('x', d => d.x)
                .attr('y', d => d.y);
        }

        function handleStepEnter(response) {
          if (MOBILE) {
            simulation
                .force('y', scrollScript[response.index].mobile())
                .alphaTarget(0.1)
                .alphaDecay(1)
                .restart();
          } else {
            simulation
                .force('x', scrollScript[response.index].desktop())
                .alphaTarget(0.1)
                .alphaDecay(1)
                .restart();
          }
        }
    }

    init();
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
  #scrolly {
      position: relative;
  }

  article {
    width: 33%;
    margin: 0 auto;
  }

  .step {
      position: relative;
      height: 100vh;
      text-align: center;
      z-index: 2;
      overflow-wrap: break-word;
  }

  .step p{
      position: absolute;
      top: 50%;
      right: 0;
      bottom: 50%;
      left: 0;
      color: #000;
  }

  svg {
      position: fixed;
      left: 0px;
      top: 0px;
      width: 100vw;
      height: 100vh;
  }

  .node {
      stroke: black;
  }
</style>
