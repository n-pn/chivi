<script context="module" lang="ts">
  export async function load({ fetch, params: { crit } }) {
    const api_res = await fetch(`/api/yscrits/${crit}`)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from '$gui/sects/yscrit/YscritCard.svelte'

  export let yscrit: CV.Yscrit

  $: topbar.set({
    left: [
      ['Đánh giá', 'stars', { href: '/crits' }],
      [`[${yscrit.id}]`, null, { href: '.', kind: 'zseed' }],
    ],
  })
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<nav class="h3 navi">
  <a class="-link" href="/crits">
    <SIcon name="messages" />
    <span>Đánh giá</span>
  </a>
  <span class="-sep">/</span>
  <a class="-link" href="/crits?by={yscrit.uslug}">
    <SIcon name="user" />
    <span>{yscrit.uname}</span>
  </a>
  <span class="-sep">/</span>
  <a class="-link" href="/crits?book={yscrit.book.id}">
    <SIcon name="book" />
    <span>{yscrit.book.btitle}</span>
  </a>
</nav>

<YscritCard crit={yscrit} view_all={true} big_text={true} />

<style lang="scss">
  .navi {
    a {
      @include fgcolor(secd);
      @include hover {
        @include fgcolor(primary, 5);
      }
    }

    .-sep {
      @include fgcolor(tert);
    }

    :global(svg) {
      margin-top: -0.25rem;
      margin-right: -0.125rem;
    }
  }
</style>
