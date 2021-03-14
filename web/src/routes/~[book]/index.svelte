<script context="module">
  import { get_nvinfo } from '$api/nvinfo_api'

  export async function preload({ params }) {
    const [err, data] = await get_nvinfo(this.fetch, params.book)
    if (err) this.error(err, data)
    else return { nvinfo: data }
  }
</script>

<script>
  import Common from './_common'

  export let nvinfo
  let short_intro = false
</script>

<Common {nvinfo} nvtab="summary">
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
