<script lang="ts">
  // import SIcon from '$gui/atoms/SIcon.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'
  import GdreplList from '$gui/parts/dboard/GdreplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ vcdata } = data)

  $: gdroot = `vc:${vcdata.crit.vc_id}`
  $: touser = vcdata.crit.vu_id
</script>

<VicritCard {...vcdata} show_book={true} view_all={true} big_text={true} />

<section id="repls" class="repls">
  <h3 class="repls-head">
    Bình luận đánh giá <span class="m-badge">{vcdata.crit.repl_count}</span>
  </h3>

  <GdreplList rplist={data.rplist} {gdroot} {touser} fluid={true} />
</section>

<style lang="scss">
  .repls-head {
    margin-bottom: 0.75rem;
  }

  .repls {
    @include bp-min(tl) {
      @include padding-x(var(--gutter));
    }
  }
</style>
