<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load({ stuff, fetch, url }) {
    const { dboard, dtopic } = stuff
    appbar.set({
      left: [
        ['Diễn đàn', 'messages', '/forum', '_show-lg'],
        [dboard.bname, null, '/forum/-' + dboard.bslug, null, '_title'],
      ],
    })

    const pg = url.searchParams.get('pg') || 1

    const api_url = `/api/tposts?dtopic=${dtopic.id}&pg=${pg}&lm=20`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.dboard = dboard
    payload.props.dtopic = dtopic
    return payload
  }
</script>

<script lang="ts">
  import { DtopicFull, DtpostList } from '$gui'

  export let dboard: CV.Dboard
  export let dtopic: CV.Dtopic
  export let tplist: CV.Tplist
</script>

<svelte:head>
  <title>{dtopic.title} - Diễn đàn - Chivi</title>
</svelte:head>

<DtopicFull {dboard} {dtopic} fluid={true} />

<dtopic-posts>
  <dtpost-head>
    <h3>Bình luận</h3>
  </dtpost-head>

  <DtpostList {tplist} {dtopic} fluid={true} />
</dtopic-posts>

<style lang="scss">
  dtopic-posts {
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

  dtpost-head {
    display: block;
    padding: 0.5rem var(--gutter);
  }
</style>
