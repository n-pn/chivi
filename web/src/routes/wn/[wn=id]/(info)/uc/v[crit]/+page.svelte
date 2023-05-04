<script lang="ts">
  // import SIcon from '$gui/atoms/SIcon.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'
  import GdreplList from '$gui/parts/dboard/GdreplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ vcdata } = data)

  $: gdroot = `vc:${vcdata.vc_id}`
  $: touser = vcdata.user_id
</script>

<h3 id="vcrit">
  Đánh giá truyện của <strong>{vcdata.u_uname}</strong> cho bộ truyện
  <strong>{vcdata.b_title}</strong>
</h3>

<VicritCard crit={vcdata} book={undefined} show_book={false} view_all={true} />

<section id="repls" class="repls">
  <h3 class="repls-head">
    Bình luận đánh giá <span class="m-badge">{vcdata.repl_count}</span>
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
