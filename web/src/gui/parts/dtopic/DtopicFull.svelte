<script lang="ts">
  import { session } from '$app/stores'
  import { rel_time } from '$utils'
  import { dlabels } from '$lib/constants'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import DtopicForm, { ctrl as dtopic_ctrl } from './DtopicForm.svelte'

  export let dtopic: Dtopic
  export let dboard: Dboard = dtopic.dboard
  export let _all = dtopic.bhtml.length < 500

  $: board_url = `/forum/-${dtopic.dboard.bslug}`
</script>

<topic-full>
  <topic-navi>
    <a href="/forum" class="m-board">
      <SIcon name="messages" />
      <span>Diễn đàn</span>
    </a>

    <navi-sep>/</navi-sep>

    <a class="m-board" href={board_url}>
      <span>{dtopic.dboard.bname}</span>
    </a>

    <navi-sep>/</navi-sep>

    {#each dtopic.labels as label}
      <a class="m-label _{label}" href="{board_url}?label={label}"
        >{dlabels[label]}</a>
    {/each}
  </topic-navi>

  <topic-head class={_all}>
    <a class="topic-title" href="{board_url}/-{dtopic.tslug}-{dtopic.id}">
      {dtopic.title}
    </a>

    <topic-foot>
      <topic-user>
        <SIcon name="edit" />
        <cv-user privi={dtopic.u_privi}>{dtopic.u_dname}</cv-user>
      </topic-user>

      <topic-sep>·</topic-sep>
      <topic-time>{rel_time(dtopic.ctime)}</topic-time>

      {#if $session.privi > 3 || $session.uname == dtopic.u_dname}
        <topic-sep>·</topic-sep>
        <topic-action on:click={() => dtopic_ctrl.show(dtopic.id)}>
          <span>Sửa</span>
        </topic-action>
      {/if}

      <foot-right>
        <topic-sep>·</topic-sep>
        <topic-meta>
          <SIcon name="messages" />
          <span>{dtopic.post_count}</span>
        </topic-meta>

        <topic-sep>·</topic-sep>
        <topic-meta>
          <SIcon name="eye" />
          <span>{dtopic.view_count}</span>
        </topic-meta>

        <topic-sep>·</topic-sep>
        <topic-meta>
          <SIcon name="star" />
          <span>{dtopic.like_count}</span>
        </topic-meta>
      </foot-right>
    </topic-foot>
  </topic-head>

  <topic-pbody class:_all>
    <article class="m-article">{@html dtopic.bhtml}</article>

    {#if dtopic.bhtml.length >= 500}
      <pbody-foot>
        <button
          class="m-btn _primary _xs btn-show"
          on:click={() => (_all = !_all)}>
          <span>{_all ? 'Thu gọn' : 'Xem hết'}</span>
        </button>
      </pbody-foot>
    {/if}
  </topic-pbody>
</topic-full>

{#if $dtopic_ctrl.actived}<DtopicForm {dboard} />{/if}

<style lang="scss">
  topic-full {
    display: block;
  }

  topic-head {
    display: block;
    // @include flex-cy($gap: 0.25rem);
    padding: 0.5rem 0 0.25rem;
    @include border($loc: bottom);
  }

  .m-board {
    @include clamp($width: null);
    max-width: 40vw;

    line-height: 1.375rem;
    @include fgcolor(tert);

    @include ftsize(sm);
    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  topic-navi {
    @include flex-cy($gap: 0.25rem);
    flex-wrap: wrap;
  }

  navi-sep {
    @include fgcolor(mute);
    @include ftsize(xs);
  }

  .m-label {
    font-size: rem(12px);
    padding: 0 0.375rem;
    line-height: 1.25rem;
  }

  .topic-title {
    display: block;
    font-weight: 500;
    line-height: 1.5rem;
    padding: 0.25rem 0;

    @include fgcolor(secd);
    @include ftsize(x2);

    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  .m-article {
    display: block;
    padding: 0.75rem 0;
    max-height: 15rem;
    overflow: hidden;
    transform: max-height 1s ease-in-out;
    font-size: rem(17px);

    ._all & {
      max-height: initial;
      overflow: initial;
    }
  }

  topic-foot {
    @include flex-cy($gap: 0.25rem);
    // line-height: 2rem;

    padding: 0.5rem 0 0.25rem;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  topic-time {
    @include clamp($width: null);
  }

  topic-meta {
    @include flex-cy;
    gap: 0.25rem;
  }

  foot-right {
    display: inline-flex;
    gap: 0.25rem;
    margin-left: auto;
  }

  topic-action {
    cursor: pointer;
    font-style: italic;

    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  // prettier-ignore
  topic-pbody {
    --hide: #{color(neutral, 7, 2)};
    display: block;
    position: relative;

    background: linear-gradient(to top, color(--hide) .25rem, transparent 1rem);
    @include border(--bd-main, $loc: bottom);
    @include tm-dark { --hide: #{color(neutral, 5, 2)}; }
    &._all { background: none; }
  }

  pbody-foot {
    @include flex-cx;
    position: absolute;
    bottom: -0.75rem;
    left: 0;
    right: 0;
    height: 1.5rem;
  }

  .btn-show {
    text-transform: uppercase;
  }
</style>
