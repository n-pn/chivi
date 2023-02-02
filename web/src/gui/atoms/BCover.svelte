<script lang="ts">
  export let bcover: string = ''
  export let scover: string = ''

  const cdn_base = 'https://cr2.chivi.app/covers/'

  $: [images, cursor] = generate_urls(bcover, scover)

  function generate_urls(bcover: string, scover: string): [string[], number] {
    const res = []

    if (bcover) res.push(cdn_base + bcover)
    if (scover) res.push(scover)

    return [res, 0]
  }

  $: srcset = images[cursor] || cdn_base + 'blank.webp'
</script>

<picture class={$$props.class || 'round'}>
  <source {srcset} />
  <img src="/imgs/empty.png" alt="" on:error={() => (cursor += 1)} />
</picture>

<style lang="scss">
  picture {
    display: block;
    position: relative;
    height: 0;
    padding-top: math.div(4, 3) * 100%;
    overflow: hidden;

    &.round {
      @include bdradi();
    }
  }

  img {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
</style>
