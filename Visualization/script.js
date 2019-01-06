'use strict'

const svg = d3.select('svg')
const width = +svg.attr('width')
const height = +svg.attr('height')
const color = d3.scaleOrdinal(d3.schemeCategory20)

const simulation = d3
    .forceSimulation()
    .force('link', d3.forceLink().id(d => d.id))
    .force('charge', d3.forceManyBody())
    .force('center', d3.forceCenter(width / 2, height / 2))

d3.json('parser-output/dependencies.json', (error, graph) => {
    if (error) throw error

    const link = svg
        .append('g')
        .attr('class', 'links')
        .selectAll('line')
        .data(graph.links)
        .enter()
        .append('line')
        .attr('stroke-width', d => Math.sqrt(6))

    const node = svg
        .append('g')
        .attr('class', 'nodes')
        .selectAll('g')
        .data(graph.nodes)
        .enter()
        .append('g')

    node.append('circle')
        .attr('r', 8)
        .attr('fill', d => color(0))

    node.append('text')
        .text(d => d.id)
        .attr('x', 6)
        .attr('y', 3)

    node.append('title').text(d => d.name)

    simulation.nodes(graph.nodes).on('tick', () => {
        link.attr('x1', d => d.source.x)
            .attr('y1', d => d.source.y)
            .attr('x2', d => d.target.x)
            .attr('y2', d => d.target.y)

        node.attr('transform', d => `translate(${d.x},${d.y})`)
    })

    simulation.force('link').links(graph.links)
})
