<script context="module">
  import Common from './_common'

  export async function preload({ params }) {
    const res = await this.fetch(`/api/nvinfos/${params.book}`)
    if (res.ok) return await res.json()
    else this.error(res.status, await res.text())
  }
</script>

<script>
  export let nvinfo
  export let nvmark = ''

  let short_intro = false
</script>

<Common {nvinfo} {nvmark} atab="summary">
  <h2>Giới thiệu:</h2>
  <div class="intro" class:_short={short_intro}>
    {#each nvinfo.bintro as para}
      <p>{para}</p>
    {/each}
  </div>
</Common>

<style lang="scss">
  .intro {
    @include fgcolor(neutral, 7);
    // @include props(padding, $md: 0 0.75rem);
    @include props(font-size, rem(15px), rem(16px), rem(17px));
    word-wrap: break-word;

    &._short {
      height: 20rem;
      overflow-y: scroll;
      scrollbar-width: thin;
      scrollbar-color: color(neutral, 8, 0.2);
    }
  }

  p {
    margin-top: 0.5rem;
  }
</style>
