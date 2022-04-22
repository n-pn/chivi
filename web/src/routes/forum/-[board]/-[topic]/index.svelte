<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load({ stuff, fetch, url }) {
    const { dboard, cvpost } = stuff

    const pg = url.searchParams.get('pg') || 1

    const api_url = `/api/tposts?cvpost=${cvpost.id}&pg=${pg}&lm=20`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.dboard = dboard
    payload.props.cvpost = cvpost
    return payload
  }
</script>

<script lang="ts">
  import { CvpostFull, CvreplList, Vessel } from '$gui'

  export let dboard: CV.Dboard
  export let cvpost: CV.Cvpost
  export let tplist: CV.Tplist

  $: board_url = `/forum/-${dboard.bslug}`
  $: topbar = {
    lefts: [
      ['Diễn đàn', 'messages', { href: '/forum', show: 'tl' }],
      [dboard.bname, 'message', { href: board_url, show: 'tm', kind: 'title' }],
      [cvpost.title, null, { href: '.', kind: 'title' }],
    ],
  }
</script>

<svelte:head>
  <title>{cvpost.title} - Diễn đàn - Chivi</title>
</svelte:head>

<Vessel {topbar} vessel="forum">
  <CvpostFull {dboard} {cvpost} fluid={true} />

  <cvpost-posts>
    <cvrepl-head>
      <h3>Bình luận</h3>
    </cvrepl-head>

    <CvreplList {tplist} {cvpost} fluid={true} />
  </cvpost-posts>
</Vessel>

<style lang="scss">
  cvpost-posts {
    display: block;
    max-width: 40rem;
    margin: 1.25rem auto 0;
    padding: 0 var(--gutter);

    @include bgcolor(secd);
    @include bdradi();
    @include shadow();

    @include tm-dark {
      @include linesd(--bd-main);
    }
  }

  cvrepl-head {
    display: block;
    padding: 0.5rem var(--gutter);
  }
</style>
