<script lang="ts">
  import { DtpostCard } from '$gui'

  let items = []
  let pgidx = 1

  $: if (pgidx) load_replies(pgidx)

  async function load_replies(pgidx) {
    const url = `/api/_self/replied?lm=10&pg=${pgidx}`
    const res = await fetch(url)
    const data = await res.json()

    if (res.ok) items = data.props
    else console.log(data.error)
  }
</script>

<dtpost-list>
  {#each items as dtpost}
    <DtpostCard {dtpost} render_mode={1} />
  {:else}
    <div class="empty">Chưa có bình luận</div>
  {/each}
</dtpost-list>

<style lang="scss">
  dtpost-list {
    display: block;
    padding: 0.25rem 0.75rem 0.75rem;
  }
</style>
