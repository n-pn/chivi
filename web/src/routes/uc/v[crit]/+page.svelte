<script lang="ts">
  // import SIcon from '$gui/atoms/SIcon.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'
  import RpnodeList from '$gui/parts/dboard/RpnodeList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: muhead = `vc:${data.crit.id}`
  $: touser = data.crit.user_id
</script>

<article class="article island _narrow">
  <h2>
    Đánh giá của <strong>{data.user.uname}</strong> cho bộ truyện
    <strong>{data.book.vtitle}</strong>
  </h2>

  <VicritCard {...data} view_all={true} />

  <section id="repls" class="replies">
    <h3 class="repls-head">Bình luận đánh giá ({data.crit.repl_count}):</h3>
    <RpnodeList rplist={data.rplist} {muhead} {touser} fluid={true} />
  </section>
</article>

<style lang="scss">
  article {
    margin-top: var(--gutter);
  }

  .repls-head {
    margin-bottom: 0.75rem;
  }

  .replies {
    @include bp-min(tl) {
      @include padding-x(var(--gutter));
    }
  }
</style>
