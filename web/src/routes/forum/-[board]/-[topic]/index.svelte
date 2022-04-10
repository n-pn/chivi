<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load({ stuff, fetch, url }) {
    const { dboard, cvpost } = stuff
    appbar.set({
      left: [
        ['Diễn đàn', 'messages', '/forum', '_show-lg'],
        [dboard.bname, null, '/forum/-' + dboard.bslug, null, '_title'],
      ],
    })

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
  import { CvpostFull, DtpostList } from '$gui'

  export let dboard: CV.Dboard
  export let cvpost: CV.Cvpost
  export let tplist: CV.Tplist
</script>

<svelte:head>
  <title>{cvpost.title} - Diễn đàn - Chivi</title>
</svelte:head>

<CvpostFull {dboard} {cvpost} fluid={true} />

<cvpost-posts>
  <cvrepl-head>
    <h3>Bình luận</h3>
  </cvrepl-head>

  <DtpostList {tplist} {cvpost} fluid={true} />
</cvpost-posts>

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
