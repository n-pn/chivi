<script lang="ts">
  export let srcset: string = ''
  export let _class = 'round'

  $: src = srcset.startsWith('/covers')
    ? `https://cdn.chivi.app${srcset}`
    : srcset

  const on_error = (e: Event) => {
    const target = e.target as HTMLImageElement
    target.src = 'https://cdn.chivi.app/covers/_blank.png'
  }
</script>

<figure class={_class}>
  <img
    {src}
    alt=""
    loading="lazy"
    referrerpolicy="no-referrer"
    on:error={on_error} />
</figure>

<style lang="scss">
  figure {
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
