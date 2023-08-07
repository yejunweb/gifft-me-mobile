<template>
    <div class="title">
        <div class="title-item">
            <p><span class="source">董驭</span>为你送来了礼物</p>
            <p>For <span class="target">WSP</span></p>
        </div>
        <div class="title-arrow">点击打开~</div>
    </div>
    <div class="loading">
        <span class="loading-icon">
            <img src="./assets/loading.svg" />
        </span>
        <div class="loading-title">加载中 0%</div>
    </div>
    <!-- 主体 -->
    <div class="container"></div>
    <!-- 卡片 -->
    <div class="card">
        <div class="card-item">
            <div class="item-reload" @click="setReload">
                <img src="./assets/reload.svg" />
            </div>
            <img src="/static/klm.gif" />
            <p>花的意义是，它为你设定期限，让你更珍惜它灿烂盛放的时刻，也告诉你，当下的这一刻很重要</p>
        </div>
    </div>
    <!-- 音乐 -->
    <audio class="audio" autoplay></audio>
</template>

<script setup>
import { onMounted } from "vue";
import $ from "jquery";
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { RoomEnvironment } from 'three/examples/jsm/environments/RoomEnvironment.js'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js'

let mixer, action // 动画实例
let progress = false // 进度
let index = 0 // 动画索引
let textList = [
    '听山河把春风酿成千言万语，吹过旧人故里',
    'Love is a vine that grows into our hearts',
    '玫瑰与山茶，温柔与浪漫',
    '桔梗花向日落献祭，灵魂不朽',
    '风需要解释，你便是',
    '玫瑰是我偷的，但浪漫判我无罪',
    '北疆、禾木、看雪',
    '日落是免费的，春夏秋冬也是，不要觉得人生那么无望，希望你快乐',
    '爱意东升西落，浪漫至死不渝',
    '情字何解 怎落笔都不对，而我独缺 你一生的了解',
    '别听世俗的耳语，去看自己喜欢的风景',
    '芦苇花开岁已寒，若霜又降路遥漫长，墙外是谁在吟唱，凤求凰',
    '花的意义是，它为你设定期限，让你更珍惜它灿烂盛放的时刻，也告诉你，当下的这一刻很重要',
    '此心昭昭若明月 千山历行 向你独行',
    '想做个快乐的小废物,混吃混喝被照顾'
]

const initialize = () => {
    const clock = new THREE.Clock()
    const container = document.querySelector('.container')

    /* 设置 WebGL 渲染器 */
    const renderer = new THREE.WebGLRenderer({
        alpha: true, // canvas是否包含alpha (透明度) 默认为 false
        antialias: true,
        precision: 'highp',
    })
    renderer.setClearAlpha(0.0) // 设置alpha，合法参数是一个 0.0 到 1.0 之间的浮点数
    renderer.setPixelRatio(window.devicePixelRatio)
    renderer.setSize(window.innerWidth, window.innerHeight)
    container.appendChild(renderer.domElement)

    /* 环境光 */
    const pmremGenerator = new THREE.PMREMGenerator(renderer)
    const scene = new THREE.Scene()
    scene.environment = pmremGenerator.fromScene(
        new RoomEnvironment(renderer),
        0.04
    ).texture

    /* 透视投影相机 */
    const camera = new THREE.PerspectiveCamera(
        40,
        window.innerWidth / window.innerHeight,
        1,
        100
    )
    camera.position.set(-10, 5, 18)

    /* 相机控件 */
    const controls = new OrbitControls(camera, renderer.domElement)
    controls.target.set(0, 0.5, 0)
    controls.update()
    controls.enablePan = false // 禁用平移
    controls.enableZoom = false // 禁用缩放
    controls.enableDamping = true // 启用阻尼系数

    /* 监听进度 */
    const manager = new THREE.LoadingManager()
    manager.onStart = (url, itemsLoaded, itemsTotal) => {
        console.log('url, itemsLoaded, itemsTotal: ', url, itemsLoaded, itemsTotal);
    }
    manager.onProgress = (url, itemsLoaded, itemsTotal) => {
        console.log('url, itemsLoaded, itemsTotal: ', url, itemsLoaded, itemsTotal);
        progress = (itemsLoaded / itemsTotal).toFixed(2) * 100
        $('.loading-title').html(`加载中 ${progress}%`)
    }
    manager.onLoad = () => {
        setTimeout(() => {
            // 设置名字
            // const source = decodeURI(window.location.search).match(/(?<=source=).*(?<=&)/)?.[0]?.replace(/&/, '')
            // const target = decodeURI(window.location.search).match(/(?<=target=).*/)?.[0]
            // if (source) $('.title-item .source').html(source)
            // if (target) $('.title-item .target').html(target)

            $('.loading').fadeOut(200)
            $('.title').fadeIn(800)
            setAudio(index)
        })
    }
    manager.onError = (url, itemsLoaded, itemsTotal) => {
        console.log('url, itemsLoaded, itemsTotal: ', url, itemsLoaded, itemsTotal);
        console.error('导入模型失败！')
    }

    /* 加载模型 */
    const dracoLoader = new DRACOLoader(manager)
    dracoLoader.setDecoderPath('/draco/gltf/') // 设置模型压缩解码库，此处路径资源文件不可被打包
    const loader = new GLTFLoader(manager)
    loader.setDRACOLoader(dracoLoader)
    loader.load(
        '/static/open-superbox.glb',
        function (gltf) {
            const model = gltf.scene
            model.position.set(0, -4.5, 0)
            model.scale.set(1.6, 1.6, 1.6)
            scene.add(model)
            /* 设置模型块显示隐藏 */
            model.children[0].children[1].visible = false // 盒子丝带-1
            model.children[0].children[3].visible = false // 盒子丝带-2
            model.children[0].children[6].visible = false // 主体盒子
            model.children[0].children[9].visible = false // 底部丝带-1
            model.children[0].children[10].visible = false // 底部丝带-2
            model.children[0].children[11].visible = false // 底部丝带-3
            model.children[0].children[12].visible = false // 底部丝带-4
            mixer = new THREE.AnimationMixer(model)
            action = mixer.clipAction(gltf.animations[index]).play()
            action.loop = THREE.LoopOnce
            action.clampWhenFinished = true
            document.body.addEventListener('click', () => {
                index += 1
                if (index === 1) {
                    $('.title-item').fadeOut(800)
                    $('.title-arrow').fadeOut(400)
                    setTimeout(() => {
                        $('.title-arrow').html('点击打开盖子~')
                        $('.title-arrow').fadeIn(400)
                    }, 400)
                    model.children[0].children[0].visible = false // 初始-盒子丝带-1
                    model.children[0].children[1].visible = true // 盒子丝带-1
                    model.children[0].children[2].visible = false // 初始-盒子丝带-2
                    model.children[0].children[3].visible = true // 盒子丝带-2
                    // model.children[0].children[4].visible = false // 初始-盒子盖子
                    model.children[0].children[5].visible = false // 初始-主体盒子
                    model.children[0].children[6].visible = true // 主体盒子
                    model.children[0].children[7].visible = false // 气体效果
                    model.children[0].children[8].visible = false // 盒子丝带
                    model.children[0].children[9].visible = true // 底部丝带-1
                    model.children[0].children[10].visible = true // 底部丝带-2
                    model.children[0].children[11].visible = true // 底部丝带-3
                    model.children[0].children[12].visible = true // 底部丝带-4
                } else if (index === 2) {
                    $('.title-arrow').fadeOut(400)
                    setTimeout(() => {
                        $('.title-arrow').html('再点一下哦~')
                        $('.title-arrow').fadeIn(400)
                    }, 400)
                    model.children[0].children[1].visible = false // 盒子丝带-1
                    model.children[0].children[3].visible = false // 盒子丝带-2
                } else if (index === 3) {
                    $('.title').fadeOut(800)
                    // 设置卡片样式
                    const textIndex = parseInt(Math.random() * textList.length)
                    $('.card-item p').html(textList[textIndex])
                    $('.card-item').css({ animation: 'card 3s ease forwards' })
                    setTimeout(() => {
                        $('.card').css({ 'background': 'rgba(255, 255, 255, 0.5)' })
                        $('.card-item > img').attr({ src: '/static/klm.gif' })
                    }, 2000)
                } else if (index === 4) {
                    return
                }
                setAudio(index)
                action = mixer.clipAction(gltf.animations[index]).play()
                action.loop = THREE.LoopOnce // 不循环
                action.clampWhenFinished = true // 结束时停止动画
            })
            animate()
        },
        undefined,
        function (e) {
            console.error(e)
        }
    )
    window.onresize = function () {
        camera.aspect = window.innerWidth / window.innerHeight
        camera.updateProjectionMatrix()
        renderer.setSize(window.innerWidth, window.innerHeight)
    }

    function animate() {
        requestAnimationFrame(animate)
        const delta = clock.getDelta()
        mixer.update(delta)
        controls.update()
        renderer.render(scene, camera)
    }

    function setAudio(index) {
        const audio = document.querySelector('.audio')
        audio.src = `/static/superbox-0${index}.mp3`
        try {
            audio.play()
        } catch (error) {
            console.log('audio.play error: ', error);
        }
    }

}

function setReload() {
    location.reload()
}

/**
 * onMounted
 */
onMounted(() => {
    initialize()
})
</script>
