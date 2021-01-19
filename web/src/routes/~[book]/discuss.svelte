<script context="module">
  import Common from './_common'

  export async function preload({ params }) {
    const res = await this.fetch(`/api/nvinfos/${params.book}`)
    const data = await res.json()

    if (res.ok) return data
    else this.error(res.status, res.text())
  }
</script>

<script>
  export let nvinfo
  export let nvmark = ''
</script>

<Common {nvinfo} {nvmark} atab="discuss">
  <div class="empty">Chưa hoàn thiện :(</div>
</Common>

<style lang="scss">
  .empty {
    min-height: 50vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include font-size(4);
    @include fgcolor(neutral, 5);
  }
</style>
