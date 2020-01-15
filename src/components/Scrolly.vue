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
        CIRCLE_RADIUS_LARGE = CIRCLE_RADIUS * 2,
        COLLIDE_RADIUS = CIRCLE_RADIUS * 1.2,
        STRENGTH = 1.5,
        WEAKER_STRENGTH = 0.2,
        WIDTH = window.innerWidth,
        HEIGHT = window.innerHeight,
        CENTER = [WIDTH / 2, HEIGHT / 2],
        LEFT_POSITION = 0,
        RIGHT_POSITION = WIDTH * (6 / 10),
        CENTER_POSITION_DESKTOP = CENTER[0] * (3 / 5),
        CENTER_POSITION_MOBILE = CENTER[1] * (3 / 5),
        UPPER_POSITION = 0,
        LOWER_POSITION = HEIGHT * (6 / 10);

    let selectedId = undefined,
        utils = undefined;

    const ageScaleDesktop = d3.scaleThreshold([30, 40, 50, 60, 70], [WIDTH / 5, WIDTH * 2 / 6, WIDTH  * 3 / 6, WIDTH * 4 / 6, WIDTH * 5 / 6, WIDTH * 6 / 6]);
    const ageScaleMobile = d3.scaleThreshold([30, 40, 50, 60, 70], [HEIGHT / 5, HEIGHT * 2 / 6, HEIGHT  * 3 / 6, HEIGHT * 4 / 6, HEIGHT * 5 / 6, HEIGHT * 6 / 6]);

    const partyScaleDesktop = d3.scaleOrdinal(['民主進步黨', '中國國民黨', '台灣民眾黨', '時代力量', '台灣基進', '無黨籍'], [LEFT_POSITION, RIGHT_POSITION, CENTER_POSITION_DESKTOP, CENTER_POSITION_DESKTOP, CENTER_POSITION_DESKTOP, CENTER_POSITION_DESKTOP]);
    const partyScaleMobile = d3.scaleOrdinal(['民主進步黨', '中國國民黨', '台灣民眾黨', '時代力量', '台灣基進', '無黨籍'], [UPPER_POSITION, LOWER_POSITION, CENTER_POSITION_MOBILE, CENTER_POSITION_MOBILE, CENTER_POSITION_MOBILE, CENTER_POSITION_MOBILE]);

    const termScaleDesktop = d3.scaleThreshold([2, 6], [LEFT_POSITION, CENTER_POSITION_DESKTOP, RIGHT_POSITION]);
    const termScaleMobile = d3.scaleThreshold([2, 6], [UPPER_POSITION, CENTER_POSITION_MOBILE, LOWER_POSITION]);

    const genderScaleDesktop = d3.scaleOrdinal(['男', '女'], [WIDTH / 6, RIGHT_POSITION]);
    const genderScaleMobile = d3.scaleOrdinal(['男', '女'], [HEIGHT / 6, LOWER_POSITION]);

    const scrollScript = [{
            step: 0,
            desktop() {
                return d3.forceX(() => CENTER[0]).strength(WEAKER_STRENGTH)
            },
            mobile() {
                return d3.forceY(() => CENTER[0]).strength(WEAKER_STRENGTH)
            },
            text: '2020立法委員選舉總共選出 <span>113</span> 名立法委員',
        },
        {
            step: 1,
            desktop() {
                return d3.forceX(d => partyScaleDesktop(d.party)).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => partyScaleMobile(d.party)).strength(STRENGTH)
            },
            text: '民進黨 <span>62</span> 席 國民黨 <span>38</span> 席 第三勢力 <span>13</span> 席',
        },
        {
            step: 2,
            desktop() {
                return d3.forceX(d => {
                    if (['陳椒華', '林昶佐', '陳柏惟', '趙正宇', '王婉諭', '邱顯智'].includes(d.name)) {
                        return LEFT_POSITION;
                    } else if (['邱臣遠', '高虹安', '蔡壁如', '張其祿', '傅崐萁', '高金素梅Ciwas Ali', '賴香伶'].includes(d.name)) {
                        return RIGHT_POSITION;
                    } else {
                        return partyScaleDesktop(d.party)
                    }
                }).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => {
                    if (['陳椒華', '林昶佐', '陳柏惟', '趙正宇', '王婉諭', '邱顯智'].includes(d.name)) {
                        return UPPER_POSITION;
                    } else if (['邱臣遠', '高虹安', '蔡壁如', '張其祿', '傅崐萁', '高金素梅Ciwas Ali', '賴香伶'].includes(d.name)) {
                        return LOWER_POSITION;
                    } else {
                        return partyScaleMobile(d.party)
                    }
                }).strength(STRENGTH)
            },
            text: '時力、基進及友綠立委算入綠營</br>台民與友藍立委算入藍營</br>綠營共 <span>68</span> 席 藍營共 <span>45</span> 席',
        },
        {
            step: 3,
            desktop() {
                const xAxis = d3.axisTop()
                   .scale(ageScaleDesktop)
                   .tickValues([30, 40, 50, 60, 70]);
                
                utils = svg.append("g")
                    .attr('class', 'axis')
                    .call(xAxis)
                    .attr('transform', "translate(" + -(WIDTH / 5) + ", " + HEIGHT * (9 / 10) + ")");

                return d3.forceX(d => ageScaleDesktop(d.age)).strength(STRENGTH)
            },
            mobile() {
                const xAxis = d3.axisRight()
                   .scale(ageScaleMobile)
                   .tickValues([30, 40, 50, 60, 70]);

                utils = svg.append("g")
                    .attr('class', 'axis')
                    .call(xAxis)
                    .attr('transform', "translate(" + WIDTH / 10 + ", " + -(HEIGHT / 6) + ")");

                return d3.forceY(d => ageScaleMobile(d.age)).strength(STRENGTH)
            },
            text: '依年齡分類</br><span>50</span> 世代人數最多</br>國民黨立委集中在 <span>60</span> 世代</br>最年輕和最年長都來自民進黨',
        },
        {
            step: 4,
            desktop() {
                return d3.forceX(d => termScaleDesktop(d.term)).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => termScaleMobile(d.term)).strength(STRENGTH)
            },
            text: '依照任期分類</br><span>38</span> 名立委是立院新鮮人</br><span>67</span> 名立委任期介於1-5屆</br><span>8</span> 名立委即將邁入第六屆以上',
        },
        {
            step: 5,
            desktop() {
                return d3.forceX(d => genderScaleDesktop(d.gender)).strength(STRENGTH)
            },
            mobile() {
                return d3.forceY(d => genderScaleMobile(d.gender)).strength(STRENGTH)
            },
            text: '依照性別分類</br><span>66</span> 名立委是男性</br><span>47</span> 名立委是女性</br>女性立委比率首度突破 <span>40%</span>',
        },
        {
            step: 6,
            desktop() {
                d3.selectAll('.node').style('pointer-events', 'none')
                    .style('cursor', 'auto');
                d3.select('#buttonContainer')
                    .transition()
                    .style('display', 'none');
                return d3.forceX(() => CENTER[0]).strength(WEAKER_STRENGTH)
            },
            mobile() {
                if (d3.select('.clicked')) {
                    d3.select('.clicked').classed('clicked', false);                
                }
                if (selectedId) {
                        d3.selectAll('.node').filter(circle => circle.id == selectedId)
                            .transition()
                            .attr("x", d => d.x)
                            .attr("y", d => d.y)
                            .attr("height", () => CIRCLE_RADIUS * 2)
                            .attr("width", () => CIRCLE_RADIUS * 2);

                        d3.select('.tooltip').transition()
                            .style("opacity", 0);
                    }

                selectedId = undefined;
                d3.selectAll('.node').style('pointer-events', 'none')
                    .style('cursor', 'auto');
                d3.select('#buttonContainer')
                    .transition()
                    .style('display', 'none');
                return d3.forceY(() => CENTER[0]).strength(WEAKER_STRENGTH)
            },
            text: '以下讀者可自行探索資料</br>可選擇各種類別分類資料</br>點擊頭像可得基本資料</br><span id="byline">製作 <a href="https://github.com/imdataman" target="_blank">林佳賢</a> <a href="https://github.com/imdataman/tw-legislator" target="_blank">Github</a></span>',
        },
        {
            step: 7,
            desktop() {
                d3.selectAll('.node').style('pointer-events', 'auto')
                    .style('cursor', 'pointer');
                d3.select('#buttonContainer')
                    .transition()
                    .style('display', 'flex');
                return d3.forceX(() => CENTER[0]).strength(WEAKER_STRENGTH)
            },
            mobile() {
                d3.selectAll('.node').style('pointer-events', 'auto')
                    .style('cursor', 'pointer');
                d3.select('#buttonContainer')
                    .transition()
                    .style('display', 'flex');
                return d3.forceY(() => CENTER[0]).strength(WEAKER_STRENGTH)
            },
            text: '',
        },
    ];

    const section = d3.select('#main').append('section').attr('id', 'scrolly');

    section.append('article')
        .selectAll('.step')
        .data(scrollScript)
        .enter().append('div')
        .attr('class', 'step')
        .append('p')
        .attr('id', d => "p" + d.step)
        .html( d => d.text);

    const svg = d3.select('#scrolly').append('svg');
    const g = svg.append('g').attr('id', 'vis');
    const tooltip = d3.select("body").append("div")
        .attr("class", "tooltip")
        .style("opacity", 0);

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
            .onStepEnter(handleStepEnter)
            .onStepExit(handleStepExit);

        window.addEventListener('resize', scroller.resize);

        const circles = g.selectAll('.node')
            .data(data)
            .enter().append('svg:image')
            .attr('class', 'node')
            .attr('width', () => CIRCLE_RADIUS * 2)
            .attr('height', () => CIRCLE_RADIUS * 2)
            .attr("xlink:href", d => './image/' + d.id + '.png')
            .style('pointer-events', 'none')
        
        if (MOBILE) {
            circles.on( 'click', d => {
                d3.event.stopPropagation();
                    simulation.stop();

                    if (selectedId) {
                        circles.filter(circle => circle.id == selectedId)
                            .transition()
                            .attr("x", d => d.x)
                            .attr("y", d => d.y)
                            .attr("height", () => CIRCLE_RADIUS * 2)
                            .attr("width", () => CIRCLE_RADIUS * 2);
                    }
                    circles.filter(circle => circle.id == d.id)
                        .raise()
                        .transition()
                        .attr("x", d => d.x - (CIRCLE_RADIUS_LARGE - CIRCLE_RADIUS))
                        .attr("y", d => d.y - (CIRCLE_RADIUS_LARGE - CIRCLE_RADIUS))
                        .attr("height", () => CIRCLE_RADIUS_LARGE * 2)
                        .attr("width", () => CIRCLE_RADIUS_LARGE * 2);

                    tooltip.transition()
                        .style("opacity", .9);

                    const imageCenter = [circles.filter(circle => circle.id == d.id).datum().x, circles.filter(circle => circle.id == d.id).datum().y]

                    tooltip.html(d.name + "</br>" + d.age + "歲</br>第" + d.term + "任")
                        .style("left", imageCenter[0] + CIRCLE_RADIUS_LARGE + (CIRCLE_RADIUS_LARGE - CIRCLE_RADIUS) + "px")
                        .style("top", imageCenter[1] + "px");

                    selectedId = d.id
                });

            svg.on( 'click', () => {
                    simulation.stop();

                    if (selectedId) {
                        circles.filter(circle => circle.id == selectedId)
                            .transition()
                            .attr("x", d => d.x)
                            .attr("y", d => d.y)
                            .attr("height", () => CIRCLE_RADIUS * 2)
                            .attr("width", () => CIRCLE_RADIUS * 2);

                        tooltip.transition()
                            .style("opacity", 0);
                    }

                    selectedId = undefined;
                });
        } else {
            circles.on( 'mouseover', d => {
                    simulation.stop();
                    circles.filter(circle => circle.id == d.id)
                        .raise()
                        .transition()
                        .attr("x", d => d.x - (CIRCLE_RADIUS_LARGE - CIRCLE_RADIUS))
                        .attr("y", d => d.y - (CIRCLE_RADIUS_LARGE - CIRCLE_RADIUS))
                        .attr("height", () => CIRCLE_RADIUS_LARGE * 2)
                        .attr("width", () => CIRCLE_RADIUS_LARGE * 2);

                    tooltip.transition()
                        .style("opacity", .9);

                    const imageCenter = [circles.filter(circle => circle.id == d.id).datum().x, circles.filter(circle => circle.id == d.id).datum().y]

                    tooltip.html(d.name + "</br>" + d.age + "歲</br>第" + d.term + "任")
                        .style("left", imageCenter[0] + CIRCLE_RADIUS_LARGE + (CIRCLE_RADIUS_LARGE - CIRCLE_RADIUS) + "px")
                        .style("top", imageCenter[1] + "px");
                })
                .on( 'mouseout', d => {
                    simulation.stop();
                    circles.filter(circle => circle.id == d.id)
                        .transition()
                        .attr("x", d => d.x)
                        .attr("y", d => d.y)
                        .attr("height", () => CIRCLE_RADIUS * 2)
                        .attr("width", () => CIRCLE_RADIUS * 2);

                    tooltip.transition()
                        .style("opacity", 0);
                });
        }

        d3.select("body").append('div')
            .attr('id', 'buttonContainer')
            .selectAll('.button')
            .data([{name: '打散', response: {index: 0}},
                {name: '政黨', response: {index: 1}},
                {name: '陣營', response: {index: 2}},
                {name: '年齡', response: {index: 3}},
                {name: '任期', response: {index: 4}},
                {name: '性別', response: {index: 5}},])
            .enter().append('div').attr('class', 'button')
            .text(d => d.name)
            .on('click', function (d) {
                if (d3.select('.clicked')) {
                    d3.select('.clicked').classed('clicked', false);                
                }
                if (selectedId) {
                        circles.filter(circle => circle.id == selectedId)
                            .transition()
                            .attr("x", d => d.x)
                            .attr("y", d => d.y)
                            .attr("height", () => CIRCLE_RADIUS * 2)
                            .attr("width", () => CIRCLE_RADIUS * 2);

                        tooltip.transition()
                            .style("opacity", 0);
                    }

                selectedId = undefined;

                d3.select(this).classed('clicked', true);
                handleStepEnter(d.response);
                if (d.response.index != 3) {handleStepExit();}
            });

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

        function handleStepExit() {
          if (utils) {
              utils.remove();
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
    width: 50%;
    margin: 0 auto;
  }

  .step {
      position: relative;
      height: 100vh;
      text-align: center;
      z-index: 2;
      overflow-wrap: break-word;
      pointer-events: none;
  }

  .step p {
      font-size: 2rem;
      position: absolute;
      padding: 1rem;
      top: 50%;
      right: 0;
      left: 0;
      height: auto;
      color: #000;
      background-color: rgba(255, 235, 205, 0.8);
      line-height: 3rem;
  }

  .step span {
       font-size: 3rem;
       font-family: Geometric;
       color: #0080ff;
  }

  #byline {
       font-size: 1rem;
       font-family: Helvetica;
       color: black;
       line-height: 1rem;
  }

  #byline a {
      color: black;
      pointer-events: auto;
  }

  svg {
      position: fixed;
      left: 0px;
      top: 0px;
      width: 100vw;
      height: 100vh;
      z-index: 1;
  }

  .axis path, .axis line {
      stroke: none;

  }

  .axis text {
      font-size: 1.5rem;
  }

  #p7 {
      display: none;
  }

  .tooltip {
    position: fixed;
    text-align: center;
    padding: 1rem;
    font-size: 1.5rem;
    background: lightsteelblue;
    border: 0px;
    pointer-events: none;
    z-index: 3;
  }

  #buttonContainer {
      position: fixed;
      width: 100px;
      height: 100%;
      left: 0px;
      top: 0px;
      flex-direction: column;
      justify-content: space-evenly;
      margin-left: 2rem;
      font-size: 1.5rem;
      text-align: center;
      display: none;
      z-index: 3;
  }

  .button {
      background-color: gainsboro;
      padding: 0.2rem 0.5rem;
      cursor: pointer;
  }

  .clicked {
      background-color: black;
      color: white;
  }

  @media only screen and (max-width: 600px) {
    .step p {
        font-size: 1rem;
        line-height: 2rem;
    }

    .step span {
      font-size: 2rem;
  }

    .axis text {
        font-size: 1rem;
    }

    article {
        width: 70%;
    }

    .tooltip {
        font-size: 1rem;
        padding: 0.5rem;
    }

    #buttonContainer {
        position: fixed;
        width: 100%;
        height: auto;
        left: 0px;
        top: 0px;
        display: none;
        flex-direction: row;
        justify-content: space-evenly;
        margin-left: 0px;
        font-size: 1rem;
    }
  }
</style>
