<script lang="ts">
  import DtpostCard from '$gui/parts/cvrepl/DtpostCard.svelte'

  let items = []
  let pgidx = 1

  $: if (pgidx) load_replies(pgidx)

  async function load_replies(pgidx: number) {
    const url = `/api/_self/replied?lm=10&pg=${pgidx}`
    const res = await fetch(url)
    const data = await res.json()

    if (res.ok) items = data.props
    else console.log(data.error)
  }
</script>

<cvrepl-list>
  {#each items as cvrepl}
    <DtpostCard {cvrepl} render_mode={1} />
  {:else}
    <div class="empty">Danh sách trống</div>
  {/each}
</cvrepl-list>

<style lang="scss">
  cvrepl-list {
    display: block;
    padding: 0.25rem 0.75rem 0.75rem;
  }
</style>
