<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import Login from './signin/Login.svelte'
  import Signup from './signin/Signup.svelte'
  import Pwtemp from './signin/Pwtemp.svelte'

  export let actived = false

  let email = ''
  let _form = 'login'
</script>

<Slider class="signin" bind:actived _rwidth={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="user" />
    </div>

    <div class="-text">Tài khoản</div>
  </svelte:fragment>

  <section class="inner">
    <div class="brand">
      <img src="/icons/chivi.svg" alt="logo" />
      <span class="-text">Chivi</span>
    </div>

    <div class="form">
      {#if _form == 'pwtemp'}
        <Pwtemp bind:email bind:_form />
      {:else if _form == 'signup'}
        <Signup bind:email bind:_form />
      {:else}
        <Login bind:email bind:_form />
      {/if}
    </div>
  </section>
</Slider>

<style lang="scss">
  .inner {
    width: 24rem;
    max-width: 100%;
    margin: 0 auto;
    margin-top: 20vh;
    padding: 1rem;
  }

  .brand {
    // font-weight: 300;
    line-height: 2.5rem;
    padding-bottom: 0.75rem;
    padding-right: 0.75rem;

    @include flex-ca;
    @include border(--bd-main, $loc: bottom);

    > .-text {
      margin-left: 0.5rem;
      @include ftsize(x3);
    }
  }

  .form {
    display: block;
    width: 24rem;
    max-width: 100%;
    padding-top: 0.75rem;
  }
</style>
